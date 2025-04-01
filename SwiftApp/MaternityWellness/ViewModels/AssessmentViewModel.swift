import Foundation
import Combine

class AssessmentViewModel: ObservableObject {
    @Published var userId: String
    @Published var assessments: [AssessmentResult] = []
    @Published var epdsQuestions: [AssessmentQuestion] = []
    @Published var phq9Questions: [AssessmentQuestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(userId: String) {
        self.userId = userId
        setupQuestions()
        loadAssessments()
    }
    
    func loadAssessments() {
        isLoading = true
        errorMessage = nil
        
        // In a real implementation, would fetch from API or local database
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // For demo purposes, generate sample data
            self.generateSampleAssessments()
            self.isLoading = false
        }
    }
    
    func saveAssessment(type: AssessmentType, score: Int, answers: [Int: Int]) -> AssessmentResult {
        isLoading = true
        
        // Convert answers to string keys for serialization
        var answerDict: [String: Int] = [:]
        for (questionId, answer) in answers {
            answerDict[String(questionId)] = answer
        }
        
        // Get interpretation based on test type and score
        let interpretation: AssessmentInterpretation
        switch type {
        case .epds:
            interpretation = getEPDSInterpretation(score: score)
        case .phq9:
            interpretation = getPHQ9Interpretation(score: score)
        }
        
        // Create assessment result
        let result = AssessmentResult(
            userId: userId,
            type: type,
            score: score,
            interpretation: interpretation,
            answers: answerDict
        )
        
        // In a real implementation, would save to API
        // For now, just update local state
        assessments.append(result)
        
        // Sort assessments by date (newest first)
        assessments.sort { $0.date > $1.date }
        
        isLoading = false
        return result
    }
    
    func getLatestAssessment() -> AssessmentResult? {
        return assessments.first
    }
    
    func getLastAssessmentByType(type: AssessmentType) -> AssessmentResult? {
        return assessments.first { $0.type == type }
    }
    
    func getLastAssessments(limit: Int) -> [AssessmentResult] {
        let sorted = assessments.sorted { $0.date > $1.date }
        return Array(sorted.prefix(limit))
    }
    
    // Setup assessment questions
    private func setupQuestions() {
        // Edinburgh Postnatal Depression Scale (EPDS) questions
        epdsQuestions = [
            AssessmentQuestion(
                id: 1,
                question: "I have been able to laugh and see the funny side of things",
                options: [
                    AssessmentOption(value: 0, label: "As much as I always could"),
                    AssessmentOption(value: 1, label: "Not quite so much now"),
                    AssessmentOption(value: 2, label: "Definitely not so much now"),
                    AssessmentOption(value: 3, label: "Not at all")
                ]
            ),
            AssessmentQuestion(
                id: 2,
                question: "I have looked forward with enjoyment to things",
                options: [
                    AssessmentOption(value: 0, label: "As much as I ever did"),
                    AssessmentOption(value: 1, label: "Rather less than I used to"),
                    AssessmentOption(value: 2, label: "Definitely less than I used to"),
                    AssessmentOption(value: 3, label: "Hardly at all")
                ]
            ),
            AssessmentQuestion(
                id: 3,
                question: "I have blamed myself unnecessarily when things went wrong",
                options: [
                    AssessmentOption(value: 3, label: "Yes, most of the time"),
                    AssessmentOption(value: 2, label: "Yes, some of the time"),
                    AssessmentOption(value: 1, label: "Not very often"),
                    AssessmentOption(value: 0, label: "No, never")
                ]
            ),
            AssessmentQuestion(
                id: 4,
                question: "I have been anxious or worried for no good reason",
                options: [
                    AssessmentOption(value: 0, label: "No, not at all"),
                    AssessmentOption(value: 1, label: "Hardly ever"),
                    AssessmentOption(value: 2, label: "Yes, sometimes"),
                    AssessmentOption(value: 3, label: "Yes, very often")
                ]
            ),
            AssessmentQuestion(
                id: 5,
                question: "I have felt scared or panicky for no very good reason",
                options: [
                    AssessmentOption(value: 3, label: "Yes, quite a lot"),
                    AssessmentOption(value: 2, label: "Yes, sometimes"),
                    AssessmentOption(value: 1, label: "No, not much"),
                    AssessmentOption(value: 0, label: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 6,
                question: "Things have been getting on top of me",
                options: [
                    AssessmentOption(value: 3, label: "Yes, most of the time I haven't been able to cope at all"),
                    AssessmentOption(value: 2, label: "Yes, sometimes I haven't been coping as well as usual"),
                    AssessmentOption(value: 1, label: "No, most of the time I have coped quite well"),
                    AssessmentOption(value: 0, label: "No, I have been coping as well as ever")
                ]
            ),
            AssessmentQuestion(
                id: 7,
                question: "I have been so unhappy that I have had difficulty sleeping",
                options: [
                    AssessmentOption(value: 3, label: "Yes, most of the time"),
                    AssessmentOption(value: 2, label: "Yes, sometimes"),
                    AssessmentOption(value: 1, label: "Not very often"),
                    AssessmentOption(value: 0, label: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 8,
                question: "I have felt sad or miserable",
                options: [
                    AssessmentOption(value: 3, label: "Yes, most of the time"),
                    AssessmentOption(value: 2, label: "Yes, quite often"),
                    AssessmentOption(value: 1, label: "Not very often"),
                    AssessmentOption(value: 0, label: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 9,
                question: "I have been so unhappy that I have been crying",
                options: [
                    AssessmentOption(value: 3, label: "Yes, most of the time"),
                    AssessmentOption(value: 2, label: "Yes, quite often"),
                    AssessmentOption(value: 1, label: "Only occasionally"),
                    AssessmentOption(value: 0, label: "No, never")
                ]
            ),
            AssessmentQuestion(
                id: 10,
                question: "The thought of harming myself has occurred to me",
                options: [
                    AssessmentOption(value: 3, label: "Yes, quite often"),
                    AssessmentOption(value: 2, label: "Sometimes"),
                    AssessmentOption(value: 1, label: "Hardly ever"),
                    AssessmentOption(value: 0, label: "Never")
                ]
            )
        ]
        
        // Patient Health Questionnaire-9 (PHQ-9) questions
        phq9Questions = [
            AssessmentQuestion(
                id: 1,
                question: "Little interest or pleasure in doing things",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 2,
                question: "Feeling down, depressed, or hopeless",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 3,
                question: "Trouble falling or staying asleep, or sleeping too much",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 4,
                question: "Feeling tired or having little energy",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 5,
                question: "Poor appetite or overeating",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 6,
                question: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 7,
                question: "Trouble concentrating on things, such as reading the newspaper or watching television",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 8,
                question: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 9,
                question: "Thoughts that you would be better off dead or of hurting yourself in some way",
                options: [
                    AssessmentOption(value: 0, label: "Not at all"),
                    AssessmentOption(value: 1, label: "Several days"),
                    AssessmentOption(value: 2, label: "More than half the days"),
                    AssessmentOption(value: 3, label: "Nearly every day")
                ]
            )
        ]
    }
    
    // For demo purposes only - generate sample data
    private func generateSampleAssessments() {
        // Clear existing assessments
        assessments = []
        
        // Current date
        let now = Date()
        let calendar = Calendar.current
        
        // Create a recent EPDS assessment
        if let date = calendar.date(byAdding: .day, value: -3, to: now) {
            let score = Int.random(in: 5...20)
            let interpretation = getEPDSInterpretation(score: score)
            
            let epdsAssessment = AssessmentResult(
                userId: userId,
                type: .epds,
                date: date,
                score: score,
                interpretation: interpretation,
                answers: [:]
            )
            
            assessments.append(epdsAssessment)
        }
        
        // Create a PHQ-9 assessment from a week ago
        if let date = calendar.date(byAdding: .day, value: -10, to: now) {
            let score = Int.random(in: 4...16)
            let interpretation = getPHQ9Interpretation(score: score)
            
            let phq9Assessment = AssessmentResult(
                userId: userId,
                type: .phq9,
                date: date,
                score: score,
                interpretation: interpretation,
                answers: [:]
            )
            
            assessments.append(phq9Assessment)
        }
        
        // Create some older assessments for history
        let assessmentTypes: [AssessmentType] = [.epds, .phq9]
        
        for i in 2...5 {
            if let date = calendar.date(byAdding: .week, value: -i, to: now) {
                let type = assessmentTypes.randomElement()!
                let score: Int
                let interpretation: AssessmentInterpretation
                
                if type == .epds {
                    score = Int.random(in: 5...20)
                    interpretation = getEPDSInterpretation(score: score)
                } else {
                    score = Int.random(in: 4...16)
                    interpretation = getPHQ9Interpretation(score: score)
                }
                
                let assessment = AssessmentResult(
                    userId: userId,
                    type: type,
                    date: date,
                    score: score,
                    interpretation: interpretation,
                    answers: [:]
                )
                
                assessments.append(assessment)
            }
        }
        
        // Sort by date (newest first)
        assessments.sort { $0.date > $1.date }
    }
}