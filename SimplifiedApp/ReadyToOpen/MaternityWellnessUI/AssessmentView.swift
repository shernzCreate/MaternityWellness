import SwiftUI

struct AssessmentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Description
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Mental Health Screenings")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(ColorTheme.textGray)
                            
                            Text("These assessments help identify potential symptoms of postpartum depression and anxiety. Your responses are private and not shared with anyone.")
                                .font(.subheadline)
                                .foregroundColor(ColorTheme.textGray)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Available Assessments
                        VStack(spacing: 15) {
                            // EPDS Assessment Card
                            NavigationLink(destination: QuestionnaireView(questionnaireType: .epds)) {
                                AssessmentCard(
                                    title: "Edinburgh Postnatal Depression Scale (EPDS)",
                                    description: "The most common screening tool for postpartum depression. 10 questions, takes about 5 minutes.",
                                    imageName: "checklist"
                                )
                            }
                            
                            // PHQ-9 Assessment Card
                            NavigationLink(destination: QuestionnaireView(questionnaireType: .phq9)) {
                                AssessmentCard(
                                    title: "Patient Health Questionnaire (PHQ-9)",
                                    description: "Helps screen for depression severity. 9 questions, takes about 3 minutes.",
                                    imageName: "square.and.pencil"
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Assessment History
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Assessment History")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textGray)
                            
                            ForEach(assessmentHistory, id: \.date) { result in
                                AssessmentResultRow(result: result)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Assessments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Sample assessment history
    let assessmentHistory = [
        AssessmentResult(
            type: "EPDS",
            score: 7,
            date: Date().addingTimeInterval(-14*24*60*60),
            interpretation: "Low risk"
        ),
        AssessmentResult(
            type: "PHQ-9", 
            score: 5, 
            date: Date().addingTimeInterval(-30*24*60*60),
            interpretation: "Mild depression"
        ),
        AssessmentResult(
            type: "EPDS", 
            score: 11, 
            date: Date().addingTimeInterval(-60*24*60*60),
            interpretation: "Possible depression"
        )
    ]
}

struct AssessmentCard: View {
    var title: String
    var description: String
    var imageName: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(ColorTheme.primaryPink)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textGray)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Start Assessment →")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.primaryPink)
                    .padding(.top, 5)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct AssessmentResult {
    let type: String
    let score: Int
    let date: Date
    let interpretation: String
}

struct AssessmentResultRow: View {
    let result: AssessmentResult
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(result.type)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textGray)
                
                Text(dateFormatter.string(from: result.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("Score: \(result.score)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.textGray)
                
                Text(result.interpretation)
                    .font(.caption)
                    .foregroundColor(interpretationColor(for: result.interpretation))
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(10)
    }
    
    func interpretationColor(for interpretation: String) -> Color {
        switch interpretation {
        case "Low risk":
            return .green
        case "Mild depression":
            return .orange
        case "Possible depression":
            return .orange
        default:
            return .red
        }
    }
}

struct AssessmentView_Previews: PreviewProvider {
    static var previews: some View {
        AssessmentView()
    }
}
