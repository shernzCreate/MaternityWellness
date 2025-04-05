import SwiftUI

struct MoodTrackerView: View {
    @Binding var selectedMood: String?
    
    let moods = [
        ("Great", "😄", "GreatMood"),
        ("Good", "🙂", "GoodMood"),
        ("Okay", "😐", "OkayMood"),
        ("Sad", "😔", "SadMood"),
        ("Terrible", "😞", "TerribleMood")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Track your mood")
                .font(.headline)
            
            Text("How are you feeling today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 10) {
                ForEach(moods, id: \.0) { mood in
                    moodButton(
                        title: mood.0,
                        emoji: mood.1,
                        colorName: mood.2,
                        isSelected: selectedMood == mood.0
                    )
                    .onTapGesture {
                        selectedMood = mood.0
                    }
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func moodButton(title: String, emoji: String, colorName: String, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(colorName).opacity(isSelected ? 1.0 : 0.3))
                    .frame(width: 50, height: 50)
                
                Text(emoji)
                    .font(.title)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? Color(colorName) : .gray)
                .fontWeight(isSelected ? .bold : .regular)
        }
        .frame(maxWidth: .infinity)
    }
}