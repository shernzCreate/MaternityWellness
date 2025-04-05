import SwiftUI

struct MoodTrackerView: View {
    @Binding var selectedMood: String
    @Environment(\.presentationMode) var presentationMode
    @State private var notes = ""
    
    let moods = [
        (emoji: "😊", name: "happy", description: "Happy"),
        (emoji: "😐", name: "neutral", description: "Neutral"),
        (emoji: "😔", name: "sad", description: "Sad"),
        (emoji: "😢", name: "depressed", description: "Depressed"),
        (emoji: "😡", name: "angry", description: "Angry")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How are you feeling?")) {
                    HStack(spacing: 20) {
                        ForEach(moods, id: \.name) { mood in
                            VStack {
                                Text(mood.emoji)
                                    .font(.system(size: 35))
                                    .padding(5)
                                    .background(selectedMood == mood.name ? Color.blue.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        selectedMood = mood.name
                                    }
                                
                                Text(mood.description)
                                    .font(.caption)
                                    .foregroundColor(selectedMood == mood.name ? .blue : .gray)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Add notes (optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: saveAndDismiss) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Mood Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func saveAndDismiss() {
        // Here we'd normally save to a database or file
        // For now, we're just updating the binding
        presentationMode.wrappedValue.dismiss()
    }
}

struct MoodTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTrackerView(selectedMood: .constant("neutral"))
    }
}
