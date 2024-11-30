import Foundation
import CoreLocation
import MapKit

// MARK: - Intake Form View Model
enum IntakeFormError: Error {
    case invalidForm
    case invalidEmail
    case invalidPhone
    case savingError
    
    var localizedDescription: String {
        switch self {
        case .invalidForm:
            return "Please fill in all required fields"
        case .invalidEmail:
            return "Invalid email address"
        case .invalidPhone:
            return "Invalid phone number"
        case .savingError:
            return "Failed to save the form"
        }
    }
}

@MainActor
class IntakeFormViewModel: ObservableObject {
    @Published var intakeForm = IntakeForm()
    @Published var savedForms: [IntakeForm] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var searchQuery = ""
    @Published var locationResults: [MKMapItem] = []
    @Published var selectedMapItem: MKMapItem?
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchCancellable: Task<Void, Never>?
    
    nonisolated init() {
        Task { @MainActor in
            loadSavedForms()
        }
    }
    
    func updateLocation(_ location: Location) {
        intakeForm.eventLocation = location
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    func searchLocation(_ query: String) async {
        searchCancellable?.cancel()
        
        guard !query.isEmpty else {
            locationResults = []
            return
        }
        
        searchCancellable = Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = query
                request.region = region
                
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                
                locationResults = response.mapItems
            } catch {
                print("Location search failed: \(error.localizedDescription)")
                locationResults = []
            }
        }
    }
    
    func selectLocation(_ mapItem: MKMapItem) {
        let location = Location(
            name: mapItem.name ?? "",
            address: mapItem.placemark.title ?? "",
            coordinate: mapItem.placemark.coordinate
        )
        updateLocation(location)
        selectedMapItem = mapItem
    }
    
    func saveForm() throws {
        // Validate required fields
        guard !intakeForm.fullName.isEmpty,
              !intakeForm.eventName.isEmpty,
              !intakeForm.emailAddress.isEmpty,
              !intakeForm.eventLocation.name.isEmpty else {
            throw IntakeFormError.invalidForm
        }
        
        // Validate email format
        guard isValidEmail(intakeForm.emailAddress) else {
            throw IntakeFormError.invalidEmail
        }
        
        // Validate phone number if provided
        if !intakeForm.phoneNumber.isEmpty {
            guard isValidPhone(intakeForm.phoneNumber) else {
                throw IntakeFormError.invalidPhone
            }
        }
        
        intakeForm.updatedAt = Date()
        if intakeForm.createdAt == Date() {
            intakeForm.createdAt = Date()
        }
        savedForms.append(intakeForm)
        
        do {
            let data = try JSONEncoder().encode(savedForms)
            UserDefaults.standard.set(data, forKey: "SavedForms")
            intakeForm = IntakeForm()
        } catch {
            throw IntakeFormError.savingError
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone.filter { $0.isNumber })
    }
    
    private func loadSavedForms() {
        if let data = UserDefaults.standard.data(forKey: "SavedForms"),
           let forms = try? JSONDecoder().decode([IntakeForm].self, from: data) {
            savedForms = forms
        }
    }
    
    private func saveForms() {
        if let data = try? JSONEncoder().encode(savedForms) {
            UserDefaults.standard.set(data, forKey: "SavedForms")
        }
    }
    
    func deleteForm(_ form: IntakeForm) {
        if let index = savedForms.firstIndex(where: { $0.id == form.id }) {
            savedForms.remove(at: index)
            saveForms()
        }
    }
    
    func updateForm(_ form: IntakeForm) {
        if let index = savedForms.firstIndex(where: { $0.id == form.id }) {
            savedForms[index] = form
            saveForms()
        }
    }
}
