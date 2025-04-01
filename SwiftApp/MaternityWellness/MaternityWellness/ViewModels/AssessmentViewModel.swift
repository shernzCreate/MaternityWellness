import SwiftUI
import Combine

class AssessmentViewModel: ObservableObject {
    @Published var assessmentResults: [AssessmentResult] = []
    @Published var currentAnswers: [String: Int] = [:]
    @Published var currentQuestionIndex = 0
    @Published var isLoading = false
    @Published var isCompleted = false
    @Published var totalScore = 0
    
    var selectedType: QuestionnaireType = .epds
    var questions: [AssessmentQuestion] = []
    
    // Get EPD Questions
    func getEPDSQuestions() -> [AssessmentQuestion] {
        return [
            AssessmentQuestion(
                id: 1,
                question: "I have been able to laugh and see the funny side of things",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "As much as I always could"),
                    AssessmentOption(id: 2, value: 1, label: "Not quite so much now"),
                    AssessmentOption(id: 3, value: 2, label: "Definitely not so much now"),
                    AssessmentOption(id: 4, value: 3, label: "Not at all")
                ]
            ),
            AssessmentQuestion(
                id: 2,
                question: "I have looked forward with enjoyment to things",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "As much as I ever did"),
                    AssessmentOption(id: 2, value: 1, label: "Rather less than I used to"),
                    AssessmentOption(id: 3, value: 2, label: "Definitely less than I used to"),
                    AssessmentOption(id: 4, value: 3, label: "Hardly at all")
                ]
            ),
            AssessmentQuestion(
                id: 3,
                question: "I have blamed myself unnecessarily when things went wrong",
                options: [
                    AssessmentOption(id: 1, value: 3, label: "Yes, most of the time"),
                    AssessmentOption(id: 2, value: 2, label: "Yes, some of the time"),
                    AssessmentOption(id: 3, value: 1, label: "Not very often"),
                    AssessmentOption(id: 4, value: 0, label: "No, never")
                ]
            ),
            AssessmentQuestion(
                id: 4,
                question: "I have been anxious or worried for no good reason",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "No, not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Hardly ever"),
                    AssessmentOption(id: 3, value: 2, label: "Yes, sometimes"),
                    AssessmentOption(id: 4, value: 3, label: "Yes, very often")
                ]
            ),
            AssessmentQuestion(
                id: 5,
                question: "I have felt scared or panicky for no very good reason",
                options: [
                    AssessmentOption(id: 1, value: 3, label: "Yes, quite a lot"),
                    AssessmentOption(id: 2, value: 2, label: "Yes, sometimes"),
                    AssessmentOption(id: 3, value: 1, label: "No, not much"),
                    AssessmentOption(id: 4, value: 0, label: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 6,
                question: "Things have been getting on top of me",
                options: [
                    AssessmentOption(id: 1, value: 3, label: "Yes, most of the time I haven't been able to cope at all"),
                    AssessmentOption(id: 2, value: 2, label: "Yes, sometimes I haven't been coping as well as usual"),
                    AssessmentOption(id: 3, value: 1, label: "No, most of the time I have coped quite well"),
                    AssessmentOption(id: 4, value: 0, label: "No, I have been coping as well as ever")
                ]
            ),
            AssessmentQuestion(
                id: 7,
                question: "I have been so unhappy that I have had difficulty sleeping",
                options: [
                    AssessmentOption(id: 1, value: 3, label: "Yes, most of the time"),
                    AssessmentOption(id: 2, value: 2, label: "Yes, sometimes"),
                    AssessmentOption(id: 3, value: 1, label: "Not very often"),
                    AssessmentOption(id: 4, value: 0, label: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 8,
                question: "I have felt sad or miserable",
                options: [
                    AssessmentOption(id: 1, value: 3, label: "Yes, most of the time"),
                    AssessmentOption(id: 2, value: 2, label: "Yes, quite often"),
                    AssessmentOption(id: 3, value: 1, label: "Not very often"),
                    AssessmentOption(id: 4, value: 0, label: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 9,
                question: "I have been so unhappy that I have been crying",
                options: [
                    AssessmentOption(id: 1, value: 3, label: "Yes, most of the time"),
                    AssessmentOption(id: 2, value: 2, label: "Yes, quite often"),
                    AssessmentOption(id: 3, value: 1, label: "Only occasionally"),
                    AssessmentOption(id: 4, value: 0, label: "No, never")
                ]
            ),
            AssessmentQuestion(
                id: 10,
                question: "The thought of harming myself has occurred to me",
                options: [
                    AssessmentOption(id: 1, value: 3, label: "Yes, quite often"),
                    AssessmentOption(id: 2, value: 2, label: "Sometimes"),
                    AssessmentOption(id: 3, value: 1, label: "Hardly ever"),
                    AssessmentOption(id: 4, value: 0, label: "Never")
                ]
            )
        ]
    }
    
    // Get PHQ-9 Questions
    func getPHQ9Questions() -> [AssessmentQuestion] {
        return [
            AssessmentQuestion(
                id: 1,
                question: "Little interest or pleasure in doing things",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 2,
                question: "Feeling down, depressed, or hopeless",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 3,
                question: "Trouble falling or staying asleep, or sleeping too much",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 4,
                question: "Feeling tired or having little energy",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 5,
                question: "Poor appetite or overeating",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 6,
                question: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 7,
                question: "Trouble concentrating on things, such as reading the newspaper or watching television",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 8,
                question: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 9,
                question: "Thoughts that you would be better off dead or of hurting yourself in some way",
                options: [
                    AssessmentOption(id: 1, value: 0, label: "Not at all"),
                    AssessmentOption(id: 2, value: 1, label: "Several days"),
                    AssessmentOption(id: 3, value: 2, label: "More than half the days"),
                    AssessmentOption(id: 4, value: 3, label: "Nearly every day")
                ]
            )
        ]
    }
    
    func startAssessment(type: QuestionnaireType) {
        selectedType = type
        currentQuestionIndex = 0
        currentAnswers = [:]
        isCompleted = false
        totalScore = 0
        
        // Load questions based on type
        switch type {
        case .epds:
            questions = getEPDSQuestions()
        case .phq9:
            questions = getPHQ9Questions()
        }
    }
    
    func answerQuestion(questionId: Int, answerValue: Int) {
        currentAnswers[String(questionId)] = answerValue
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            completeAssessment()
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func completeAssessment() {
        // Calculate total score
        totalScore = currentAnswers.values.reduce(0, +)
        
        // Create result
        let result = AssessmentResult(
            id: UUID().uuidString,
            userId: "current-user-id", // In real app, get from auth
            type: selectedType.rawValue,
            score: totalScore,
            answers: currentAnswers,
            date: Date()
        )
        
        // Save result
        assessmentResults.append(result)
        isCompleted = true
    }
    
    // Function to get previous assessments, in a real app would fetch from API/storage
    func loadPreviousAssessments() {
        isLoading = true
        
        // Simulating API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // This would typically come from an API or local storage
            // For demo, we're creating some sample data
            if self.assessmentResults.isEmpty {
                // Only add sample data if there are no results yet
                let sampleData: [AssessmentResult] = [
                    AssessmentResult(
                        id: UUID().uuidString,
                        userId: "current-user-id",
                        type: QuestionnaireType.epds.rawValue,
                        score: 7,
                        answers: ["1": 1, "2": 0, "3": 1, "4": 1, "5": 0, "6": 1, "7": 1, "8": 1, "9": 1, "10": 0],
                        date: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                    ),
                    AssessmentResult(
                        id: UUID().uuidString,
                        userId: "current-user-id",
                        type: QuestionnaireType.phq9.rawValue,
                        score: 5,
                        answers: ["1": 1, "2": 1, "3": 1, "4": 0, "5": 0, "6": 1, "7": 0, "8": 1, "9": 0],
                        date: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
                    )
                ]
                
                self.assessmentResults = sampleData
            }
            
            self.isLoading = false
        }
    }
}