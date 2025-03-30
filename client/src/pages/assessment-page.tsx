import { useState } from "react";
import { useLocation } from "wouter";
import { useMutation } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { ArrowLeft, Check } from "lucide-react";
import { AssessmentForm } from "@/components/assessment-form";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useAuth } from "@/hooks/use-auth";

// Assessment questions based on Edinburgh Postnatal Depression Scale (EPDS)
const assessmentQuestions = [
  {
    id: 1,
    question: "I have been able to laugh and see the funny side of things",
    options: [
      { value: 0, label: "As much as I always could" },
      { value: 1, label: "Not quite so much now" },
      { value: 2, label: "Definitely not so much now" },
      { value: 3, label: "Not at all" }
    ]
  },
  {
    id: 2,
    question: "I have looked forward with enjoyment to things",
    options: [
      { value: 0, label: "As much as I ever did" },
      { value: 1, label: "Rather less than I used to" },
      { value: 2, label: "Definitely less than I used to" },
      { value: 3, label: "Hardly at all" }
    ]
  },
  {
    id: 3,
    question: "I have blamed myself unnecessarily when things went wrong",
    options: [
      { value: 0, label: "No, never" },
      { value: 1, label: "Not very often" },
      { value: 2, label: "Yes, some of the time" },
      { value: 3, label: "Yes, most of the time" }
    ]
  },
  {
    id: 4,
    question: "I have been anxious or worried for no good reason",
    options: [
      { value: 0, label: "No, not at all" },
      { value: 1, label: "Hardly ever" },
      { value: 2, label: "Yes, sometimes" },
      { value: 3, label: "Yes, very often" }
    ]
  },
  {
    id: 5,
    question: "I have felt scared or panicky for no very good reason",
    options: [
      { value: 0, label: "No, not at all" },
      { value: 1, label: "No, not much" },
      { value: 2, label: "Yes, sometimes" },
      { value: 3, label: "Yes, quite a lot" }
    ]
  },
  {
    id: 6,
    question: "Things have been getting on top of me",
    options: [
      { value: 0, label: "No, I have been coping as well as ever" },
      { value: 1, label: "No, most of the time I have coped quite well" },
      { value: 2, label: "Yes, sometimes I haven't been coping as well as usual" },
      { value: 3, label: "Yes, most of the time I haven't been able to cope at all" }
    ]
  },
  {
    id: 7,
    question: "I have been so unhappy that I have had difficulty sleeping",
    options: [
      { value: 0, label: "No, not at all" },
      { value: 1, label: "Not very often" },
      { value: 2, label: "Yes, sometimes" },
      { value: 3, label: "Yes, most of the time" }
    ]
  },
  {
    id: 8,
    question: "I have felt sad or miserable",
    options: [
      { value: 0, label: "No, not at all" },
      { value: 1, label: "Not very often" },
      { value: 2, label: "Yes, quite often" },
      { value: 3, label: "Yes, most of the time" }
    ]
  },
  {
    id: 9,
    question: "I have been so unhappy that I have been crying",
    options: [
      { value: 0, label: "No, never" },
      { value: 1, label: "Only occasionally" },
      { value: 2, label: "Yes, quite often" },
      { value: 3, label: "Yes, most of the time" }
    ]
  },
  {
    id: 10,
    question: "The thought of harming myself has occurred to me",
    options: [
      { value: 0, label: "Never" },
      { value: 1, label: "Hardly ever" },
      { value: 2, label: "Sometimes" },
      { value: 3, label: "Yes, quite often" }
    ]
  }
];

export default function AssessmentPage() {
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [isComplete, setIsComplete] = useState(false);
  const [, navigate] = useLocation();
  const { user } = useAuth();

  const totalQuestions = assessmentQuestions.length;
  const currentProgress = (currentQuestionIndex / totalQuestions) * 100;
  const currentQuestion = assessmentQuestions[currentQuestionIndex];

  const assessmentMutation = useMutation({
    mutationFn: async (data: { score: number, answers: Record<number, number> }) => {
      const res = await apiRequest("POST", "/api/assessments", data);
      return res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/assessments/latest"] });
    }
  });

  const handleAnswer = (value: number) => {
    // Save the answer
    const newAnswers = { ...answers, [currentQuestion.id]: value };
    setAnswers(newAnswers);
    
    // Move to next question or complete
    if (currentQuestionIndex < totalQuestions - 1) {
      setCurrentQuestionIndex(currentQuestionIndex + 1);
    } else {
      completeAssessment(newAnswers);
    }
  };

  const handlePrevious = () => {
    if (currentQuestionIndex > 0) {
      setCurrentQuestionIndex(currentQuestionIndex - 1);
    }
  };

  const completeAssessment = (finalAnswers: Record<number, number>) => {
    // Calculate total score
    const totalScore = Object.values(finalAnswers).reduce((sum, value) => sum + value, 0);
    
    // Submit assessment
    assessmentMutation.mutateAsync({
      score: totalScore,
      answers: finalAnswers
    });
    
    setIsComplete(true);
  };

  const interpretScore = (score: number) => {
    if (score <= 8) return { level: "Low risk", color: "bg-success" };
    if (score <= 12) return { level: "Moderate concern", color: "bg-warning" };
    return { level: "High concern", color: "bg-destructive" };
  };

  const calculateTotalScore = () => {
    return Object.values(answers).reduce((sum, value) => sum + value, 0);
  };

  return (
    <div className="min-h-screen bg-white">
      <div className="bg-primary text-white px-4 py-6">
        <div className="flex items-center">
          <Button 
            variant="ghost" 
            size="icon" 
            className="mr-3 text-white hover:bg-primary-dark" 
            onClick={() => navigate('/')}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <h1 className="font-bold text-xl">Wellness Check-In</h1>
        </div>
        
        <div className="mt-4 bg-white bg-opacity-10 rounded-xl p-3">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm">Progress</span>
            <span className="text-sm font-medium">
              Question {currentQuestionIndex + 1} of {totalQuestions}
            </span>
          </div>
          <Progress 
            value={currentProgress} 
            className="bg-white bg-opacity-20 h-2" 
            indicatorClassName="bg-white" 
          />
        </div>
      </div>
      
      {/* Question or Completion Screen */}
      <div className="px-4 py-6">
        {!isComplete ? (
          <div className="question">
            <h2 className="font-semibold text-lg mb-4">{currentQuestion.question}</h2>
            
            <div className="space-y-3 mb-8">
              {currentQuestion.options.map((option) => (
                <Button
                  key={option.value}
                  variant="outline"
                  className="w-full justify-start p-4 h-auto text-left font-normal"
                  onClick={() => handleAnswer(option.value)}
                >
                  <div className="flex items-center">
                    <span>{option.label}</span>
                  </div>
                </Button>
              ))}
            </div>
            
            <div className="flex justify-between">
              <Button 
                variant="outline" 
                onClick={handlePrevious}
                disabled={currentQuestionIndex === 0}
              >
                Previous
              </Button>
            </div>
          </div>
        ) : (
          <div className="completion-screen">
            <div className="text-center mb-8">
              <div className="w-20 h-20 bg-success bg-opacity-20 rounded-full flex items-center justify-center mx-auto mb-4">
                <Check className="h-8 w-8 text-success" />
              </div>
              <h2 className="font-bold text-xl mb-2">Assessment Complete</h2>
              <p className="text-muted-foreground">Thank you for completing today's wellness check-in.</p>
            </div>
            
            <Card className="mb-8">
              <CardContent className="pt-6">
                <h3 className="font-semibold text-lg mb-3">Your Insights</h3>
                
                {/* Score interpretation */}
                <div className="mb-4">
                  <div className="flex justify-between items-center mb-1">
                    <span className="text-sm font-medium">Overall Wellbeing</span>
                    <span className="text-xs text-muted-foreground">
                      {interpretScore(calculateTotalScore()).level}
                    </span>
                  </div>
                  <Progress 
                    value={100 - (calculateTotalScore() / 30) * 100} 
                    className="h-2"
                    indicatorClassName={interpretScore(calculateTotalScore()).color}
                  />
                </div>
                
                <div className="mb-4">
                  <div className="flex justify-between items-center mb-1">
                    <span className="text-sm font-medium">Energy</span>
                    <span className="text-xs text-muted-foreground">
                      {calculateTotalScore() > 15 ? "Low" : "Moderate"}
                    </span>
                  </div>
                  <Progress 
                    value={100 - (calculateTotalScore() / 30) * 100 - 10} 
                    className="h-2"
                    indicatorClassName={calculateTotalScore() > 15 ? "bg-warning" : "bg-success"}
                  />
                </div>
                
                <div className="mb-4">
                  <div className="flex justify-between items-center mb-1">
                    <span className="text-sm font-medium">Self-care</span>
                    <span className="text-xs text-muted-foreground">
                      Needs attention
                    </span>
                  </div>
                  <Progress 
                    value={60} 
                    className="h-2"
                    indicatorClassName="bg-success"
                  />
                </div>
              </CardContent>
            </Card>
            
            <div className="flex flex-col space-y-3">
              <Button 
                onClick={() => navigate('/care-plan')}
                className="bg-primary hover:bg-primary-dark"
              >
                View Your Care Plan
              </Button>
              <Button 
                variant="outline"
                onClick={() => navigate('/')}
              >
                Return to Dashboard
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
