import Foundation
import CoreLocation

struct IntakeForm: Identifiable, Codable {
    var id = UUID()
    var fullName: String = ""
    var emailAddress: String = ""
    var phoneNumber: String = ""
    var eventName: String = ""
    var eventDate: Date = Date()
    var eventTime: Date = Date()
    var eventLocation: Location = Location()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init() {}
}

struct Location: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(name: String = "", address: String = "", coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()) {
        self.name = name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = address
    }
}

extension Location {
    enum CodingKeys: String, CodingKey {
        case name, latitude, longitude, address
    }
}

extension IntakeForm {
    enum CodingKeys: String, CodingKey {
        case id, fullName, emailAddress, phoneNumber, eventName, eventDate, eventTime, eventLocation, createdAt, updatedAt
    }
}
