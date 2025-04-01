import Foundation

struct AssessmentQuestion: Identifiable {
    var id: Int
    var question: String
    var options: [AssessmentOption]
}

struct AssessmentOption: Identifiable {
    var id: Int
    var value: Int
    var label: String
}

enum QuestionnaireType: String, CaseIterable {
    case epds = "Edinburgh Postnatal Depression Scale"
    case phq9 = "Patient Health Questionnaire-9"
    
    var shortName: String {
        switch self {
        case .epds: return "EPDS"
        case .phq9: return "PHQ-9"
        }
    }
    
    var description: String {
        switch self {
        case .epds:
            return "A 10-item questionnaire designed to identify women who may be experiencing postnatal depression."
        case .phq9:
            return "A 9-item questionnaire used to screen, diagnose, monitor, and measure the severity of depression."
        }
    }
}

struct AssessmentResult: Identifiable, Codable {
    var id: String
    var userId: String
    var type: String
    var score: Int
    var answers: [String: Int]
    var date: Date
    
    var interpretation: String {
        if type == QuestionnaireType.epds.rawValue {
            return interpretEPDS(score: score)
        } else if type == QuestionnaireType.phq9.rawValue {
            return interpretPHQ9(score: score)
        }
        return "Unknown assessment type"
    }
    
    var severityColor: String {
        if type == QuestionnaireType.epds.rawValue {
            return epdsColor(score: score)
        } else if type == QuestionnaireType.phq9.rawValue {
            return phq9Color(score: score)
        }
        return "gray"
    }
    
    private func interpretEPDS(score: Int) -> String {
        switch score {
        case 0...8: return "Low likelihood of depression"
        case 9...12: return "Possible depression, consider follow-up"
        case 13...30: return "Probable depression, seek professional help"
        default: return "Invalid score"
        }
    }
    
    private func interpretPHQ9(score: Int) -> String {
        switch score {
        case 0...4: return "Minimal depression"
        case 5...9: return "Mild depression"
        case 10...14: return "Moderate depression"
        case 15...19: return "Moderately severe depression"
        case 20...27: return "Severe depression"
        default: return "Invalid score"
        }
    }
    
    private func epdsColor(score: Int) -> String {
        switch score {
        case 0...8: return "green"
        case 9...12: return "yellow"
        case 13...30: return "red"
        default: return "gray"
        }
    }
    
    private func phq9Color(score: Int) -> String {
        switch score {
        case 0...4: return "green"
        case 5...9: return "lightGreen"
        case 10...14: return "yellow"
        case 15...19: return "orange"
        case 20...27: return "red"
        default: return "gray"
        }
    }
}