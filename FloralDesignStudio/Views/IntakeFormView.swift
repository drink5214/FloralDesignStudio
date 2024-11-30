import SwiftUI
import MapKit

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct RequiredField: ViewModifier {
    let isRequired: Bool
    
    func body(content: Content) -> some View {
        HStack {
            content
            if isRequired {
                Text("*")
                    .foregroundColor(.red)
                    .font(.caption)
                    .accessibilityLabel("Required field")
            }
        }
    }
}

extension View {
    func required(_ isRequired: Bool = true) -> some View {
        modifier(RequiredField(isRequired: isRequired))
    }
}

struct MapView: View {
    let coordinate: CLLocationCoordinate2D
    
    var body: some View {
        Map {
            Marker("Event Location", coordinate: coordinate)
        }
        .frame(height: 150)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .disabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Map showing event location")
    }
}

struct IntakeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: IntakeFormViewModel
    @State private var showingLocationSearch = false
    @State private var showingUnsavedChangesAlert = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case name, email, phone, eventName, eventDate, eventTime
    }
    
    private var hasUnsavedChanges: Bool {
        !viewModel.intakeForm.fullName.isEmpty ||
        !viewModel.intakeForm.emailAddress.isEmpty ||
        !viewModel.intakeForm.phoneNumber.isEmpty ||
        !viewModel.intakeForm.eventName.isEmpty ||
        !viewModel.intakeForm.eventLocation.name.isEmpty
    }
    
    init(viewModel: IntakeFormViewModel? = nil) {
        let vm = viewModel ?? IntakeFormViewModel()
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(white: 0.98)
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Full Name", text: $viewModel.intakeForm.fullName)
                            .textContentType(.name)
                            .focused($focusedField, equals: .name)
                            .required()
                            .accessibilityLabel("Enter full name (required)")
                        
                        TextField("Email Address", text: $viewModel.intakeForm.emailAddress)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .email)
                            .required()
                            .accessibilityLabel("Enter email address (required)")
                        
                        TextField("Phone Number", text: $viewModel.intakeForm.phoneNumber)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phone)
                            .required()
                            .accessibilityLabel("Enter phone number (required)")
                    } header: {
                        Text("Personal Information")
                            .required()
                    }
                    
                    Section {
                        TextField("Event Name", text: $viewModel.intakeForm.eventName)
                            .focused($focusedField, equals: .eventName)
                            .required()
                            .accessibilityLabel("Enter event name (required)")
                        
                        DatePicker("Event Date",
                                  selection: $viewModel.intakeForm.eventDate,
                                  in: Date()...,
                                  displayedComponents: .date)
                            .focused($focusedField, equals: .eventDate)
                            .required()
                            .accessibilityLabel("Select event date (required)")
                        
                        DatePicker("Event Time",
                                  selection: $viewModel.intakeForm.eventTime,
                                  displayedComponents: .hourAndMinute)
                            .focused($focusedField, equals: .eventTime)
                            .required()
                            .accessibilityLabel("Select event time (required)")
                    } header: {
                        Text("Event Details")
                            .required()
                    }
                    
                    Section {
                        Button(action: {
                            showingLocationSearch = true
                        }) {
                            HStack {
                                Text(viewModel.intakeForm.eventLocation.name.isEmpty ? "Select Location" : viewModel.intakeForm.eventLocation.name)
                                    .foregroundColor(viewModel.intakeForm.eventLocation.name.isEmpty ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .accessibilityLabel(viewModel.intakeForm.eventLocation.name.isEmpty ? "Select event location (required)" : "Change event location")
                        
                        if !viewModel.intakeForm.eventLocation.name.isEmpty {
                            Text(viewModel.intakeForm.eventLocation.address)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            MapView(coordinate: viewModel.intakeForm.eventLocation.coordinate)
                        }
                    } header: {
                        Text("Event Location")
                            .required()
                    }
                }
                .scrollContentBackground(.hidden)
                .disabled(isLoading)
                
                if isLoading {
                    ProgressView("Saving...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .navigationTitle("Client Information")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    if hasUnsavedChanges {
                        showingUnsavedChangesAlert = true
                    } else {
                        dismiss()
                    }
                }
                .foregroundColor(AppColors.forestGreen),
                trailing: Button(action: {
                    do {
                        try viewModel.saveForm()
                        dismiss()
                    } catch let error as IntakeFormError {
                        errorMessage = error.localizedDescription
                        showingError = true
                    } catch {
                        errorMessage = "An unexpected error occurred"
                        showingError = true
                    }
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.forestGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid || isLoading)
                .foregroundColor(isFormValid ? AppColors.forestGreen : .gray)
            )
            .sheet(isPresented: $showingLocationSearch) {
                LocationSearchView(viewModel: viewModel)
            }
            .alert("Unsaved Changes", isPresented: $showingUnsavedChangesAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) { }
            } message: {
                Text("You have unsaved changes. Are you sure you want to discard them?")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onSubmit {
                switch focusedField {
                case .name:
                    focusedField = .email
                case .email:
                    focusedField = .phone
                case .phone:
                    focusedField = .eventName
                case .eventName:
                    focusedField = .eventDate
                case .eventDate:
                    focusedField = .eventTime
                case .eventTime:
                    focusedField = nil
                case .none:
                    break
                }
            }
        }
    }
    
    var isFormValid: Bool {
        !viewModel.intakeForm.fullName.isEmpty &&
        !viewModel.intakeForm.eventName.isEmpty &&
        !viewModel.intakeForm.emailAddress.isEmpty &&
        !viewModel.intakeForm.eventLocation.name.isEmpty
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
}

struct LocationSearchView: View {
    @ObservedObject var viewModel: IntakeFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        NavigationView {
            List {
                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Text("No locations found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(searchResults, id: \.self) { item in
                        Button {
                            selectLocation(item)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.name ?? "")
                                    .foregroundColor(.primary)
                                Text(item.placemark.formattedAddress)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Location")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                searchLocations(query: newValue)
            }
        }
    }
    
    private func searchLocations(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            if let error = error {
                print("Location search failed: \(error.localizedDescription)")
                return
            }
            
            searchResults = response?.mapItems ?? []
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        viewModel.intakeForm.eventLocation = Location(
            name: item.name ?? "",
            address: item.placemark.formattedAddress,
            coordinate: item.placemark.coordinate
        )
        dismiss()
    }
}

extension CLPlacemark {
    var formattedAddress: String {
        let components = [subThoroughfare, thoroughfare, locality, administrativeArea, postalCode]
            .compactMap { $0 }
        return components.joined(separator: " ")
    }
}

struct IntakeFormListView: View {
    @StateObject private var viewModel = IntakeFormViewModel()
    @State private var showingNewForm = false
    @State private var selectedForm: IntakeForm?
    
    var body: some View {
        List {
            ForEach(viewModel.savedForms) { form in
                Button(action: {
                    selectedForm = form
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(form.eventName)
                            .font(.headline)
                        Text(form.fullName)
                            .foregroundColor(.gray)
                        Text(form.eventDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.deleteForm(viewModel.savedForms[index])
                }
            }
        }
        .navigationTitle("Client Forms")
        .navigationBarItems(trailing: Button(action: {
            showingNewForm = true
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingNewForm) {
            IntakeFormView()
        }
        .sheet(item: $selectedForm) { form in
            NavigationView {
                IntakeFormDetailView(form: form, viewModel: viewModel)
            }
        }
    }
}

struct IntakeFormDetailView: View {
    let form: IntakeForm
    @ObservedObject var viewModel: IntakeFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background image with opacity
            Image("background")
                .resizable()
                .scaledToFill()
                .opacity(0.3)
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Title area
                Text("Form Details")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.forestGreen)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                // Content area with light background
                ScrollView {
                    VStack(spacing: 20) {
                        // Personal Information Section
                        GroupBox(label: Label("Personal Information", systemImage: "person.fill")
                            .foregroundColor(AppColors.forestGreen)) {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(label: "Full Name", value: form.fullName)
                                InfoRow(label: "Email", value: form.emailAddress)
                                InfoRow(label: "Phone", value: form.phoneNumber)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Event Details Section
                        GroupBox(label: Label("Event Details", systemImage: "calendar")
                            .foregroundColor(AppColors.forestGreen)) {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(label: "Event Name", value: form.eventName)
                                InfoRow(label: "Date", value: form.eventDate.formatted(date: .long, time: .omitted))
                                InfoRow(label: "Time", value: form.eventTime.formatted(date: .omitted, time: .shortened))
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Location Section
                        GroupBox(label: Label("Event Location", systemImage: "mappin.and.ellipse")
                            .foregroundColor(AppColors.forestGreen)) {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(label: "Venue", value: form.eventLocation.name)
                                Text(form.eventLocation.address)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                MapView(coordinate: form.eventLocation.coordinate)
                                    .frame(height: 150)
                                    .cornerRadius(10)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Delete Button
                        Button(role: .destructive) {
                            viewModel.deleteForm(form)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Form")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .background(Color(white: 0.98))
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Done") {
            dismiss()
        }
        .foregroundColor(AppColors.forestGreen))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
        }
    }
}

#Preview {
    IntakeFormView()
}
