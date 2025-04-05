import SwiftUI

struct AssessmentView: View {
    let assessments = [
        (name: "EPDS", fullName: "Edinburgh Postnatal Depression Scale", description: "A 10-item questionnaire to identify symptoms of depression during pregnancy and after childbirth.", lastTaken: ""),
        (name: "PHQ-9", fullName: "Patient Health Questionnaire", description: "A 9-item questionnaire to screen, diagnose, monitor and measure the severity of depression.", lastTaken: "")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Available Questionnaires")) {
                    ForEach(assessments, id: \.name) { assessment in
                        NavigationLink(destination: QuestionnaireView(assessmentType: assessment.name)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(assessment.fullName)
                                    .font(.headline)
                                
                                Text(assessment.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                
                                if !assessment.lastTaken.isEmpty {
                                    Text("Last taken: \(assessment.lastTaken)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                Section(header: Text("About Assessments")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Why take these questionnaires?")
                            .font(.headline)
                        
                        Text("These standardized questionnaires are used by healthcare professionals worldwide to screen for symptoms of depression and anxiety during pregnancy and the postpartum period.")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("Important Note")
                            .font(.headline)
                            .padding(.top, 5)
                        
                        Text("These assessments are not diagnostic tools. If you're experiencing distress or have concerns about your mental health, please consult a healthcare professional.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Assessments")
        }
    }
}

struct AssessmentView_Previews: PreviewProvider {
    static var previews: some View {
        AssessmentView()
    }
}
