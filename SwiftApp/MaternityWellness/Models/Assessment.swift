import Foundation

enum AssessmentType: String, CaseIterable, Codable {
    case epds = "EPDS"
    case phq9 = "PHQ-9"
}

struct AssessmentOption: Identifiable {
    var id: Int { value }
    var value: Int
    var label: String
}

struct AssessmentQuestion: Identifiable {
    var id: Int
    var question: String
    var options: [AssessmentOption]
}

struct AssessmentInterpretation: Codable {
    var severity: String
    var description: String
    var color: String
}

struct AssessmentResult: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var type: AssessmentType
    var date: Date = Date()
    var score: Int
    var interpretation: AssessmentInterpretation
    var answers: [String: Int] // Question ID to answer value
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case type
        case date
        case score
        case interpretation
        case answers
    }
}

// EPDS Interpretation helper
func getEPDSInterpretation(score: Int) -> AssessmentInterpretation {
    switch score {
    case 0...8:
        return AssessmentInterpretation(
            severity: "Low Likelihood",
            description: "Your score suggests a low likelihood of depression",
            color: "Green"
        )
    case 9...12:
        return AssessmentInterpretation(
            severity: "Possible Depression",
            description: "Your score suggests possible depression",
            color: "Yellow"
        )
    default:
        return AssessmentInterpretation(
            severity: "Probable Depression",
            description: "Your score suggests probable depression",
            color: "Red"
        )
    }
}

// PHQ-9 Interpretation helper
func getPHQ9Interpretation(score: Int) -> AssessmentInterpretation {
    switch score {
    case 0...4:
        return AssessmentInterpretation(
            severity: "Minimal",
            description: "Your score suggests minimal depression symptoms",
            color: "Green"
        )
    case 5...9:
        return AssessmentInterpretation(
            severity: "Mild",
            description: "Your score suggests mild depression symptoms",
            color: "LightGreen"
        )
    case 10...14:
        return AssessmentInterpretation(
            severity: "Moderate",
            description: "Your score suggests moderate depression symptoms",
            color: "Yellow"
        )
    case 15...19:
        return AssessmentInterpretation(
            severity: "Moderately Severe",
            description: "Your score suggests moderately severe depression symptoms",
            color: "Orange"
        )
    default:
        return AssessmentInterpretation(
            severity: "Severe",
            description: "Your score suggests severe depression symptoms",
            color: "Red"
        )
    }
}