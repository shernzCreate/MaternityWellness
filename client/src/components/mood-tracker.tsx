import { useState } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { 
  SmilePlus, 
  Smile, 
  Meh, 
  Frown, 
  Moon,
  Loader2
} from "lucide-react";

interface Mood {
  id: number;
  userId: number;
  date: string;
  mood: string;
  notes?: string;
}

const moods = [
  { id: "happy", label: "Happy", icon: SmilePlus },
  { id: "okay", label: "Okay", icon: Smile },
  { id: "sad", label: "Sad", icon: Meh },
  { id: "angry", label: "Angry", icon: Frown },
  { id: "tired", label: "Tired", icon: Moon },
];

export function MoodTracker() {
  const [selectedMood, setSelectedMood] = useState<string | null>(null);
  const { toast } = useToast();
  
  // Check if mood was already tracked today
  const { data: todaysMood, isLoading: checkingMood } = useQuery({
    queryKey: ["/api/moods/today"],
    queryFn: async () => {
      try {
        const response = await fetch("/api/moods/today");
        if (!response.ok) {
          if (response.status === 404) {
            return null;
          }
          throw new Error("Failed to fetch today's mood");
        }
        return await response.json();
      } catch (error) {
        console.error("Error fetching mood:", error);
        return null;
      }
    }
  });

  // Track mood mutation
  const moodMutation = useMutation({
    mutationFn: async ({ mood, notes }: { mood: string, notes?: string }) => {
      const res = await apiRequest("POST", "/api/moods", { mood, notes });
      return res.json();
    },
    onSuccess: () => {
      toast({
        title: "Mood tracked",
        description: "Your mood has been recorded for today.",
      });
      queryClient.invalidateQueries({ queryKey: ["/api/moods/today"] });
    },
    onError: (error) => {
      toast({
        title: "Failed to track mood",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  const handleMoodSelection = (moodId: string) => {
    // If there's already a tracked mood today, don't allow changing
    if (todaysMood) {
      toast({
        title: "Mood already tracked",
        description: "You've already tracked your mood today.",
        variant: "default",
      });
      return;
    }
    
    setSelectedMood(moodId);
    moodMutation.mutate({ mood: moodId });
  };

  if (checkingMood) {
    return (
      <div className="flex justify-center py-2">
        <Loader2 className="h-6 w-6 animate-spin text-white" />
      </div>
    );
  }

  // Display tracked mood or selection buttons
  return (
    <div className="flex justify-between">
      {moods.map((mood) => {
        const MoodIcon = mood.icon;
        const isSelected = todaysMood ? todaysMood.mood === mood.id : selectedMood === mood.id;
        
        return (
          <button 
            key={mood.id}
            className="flex flex-col items-center" 
            onClick={() => handleMoodSelection(mood.id)}
            disabled={todaysMood !== null || moodMutation.isPending}
          >
            <div 
              className={`w-12 h-12 rounded-full flex items-center justify-center mb-1 transition-all
                ${isSelected 
                  ? 'bg-white text-primary' 
                  : 'bg-white bg-opacity-20 hover:bg-opacity-30'}`}
            >
              <MoodIcon className={`text-2xl ${moodMutation.isPending && selectedMood === mood.id ? 'animate-pulse' : ''}`} />
            </div>
            <span className="text-xs">{mood.label}</span>
          </button>
        );
      })}
    </div>
  );
}
