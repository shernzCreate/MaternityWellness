import { useState } from "react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/ui/card";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { ArrowLeft, ArrowRight, CheckCircle2, AlertTriangle } from "lucide-react";
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/use-auth";
import { useMutation } from "@tanstack/react-query";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { getEpdsInterpretation, getPhq9Interpretation } from "@/lib/assessmentData";

export interface QuestionnaireQuestion {
  id: number;
  question: string;
  options: {
    value: number;
    label: string;
  }[];
}

interface QuestionnaireFormProps {
  title: string;
  description: string;
  questionnaire: "epds" | "phq9";
  questions: QuestionnaireQuestion[];
  onComplete?: (score: number, answers: Record<number, number>) => void;
}

export function QuestionnaireForm({ 
  title, 
  description, 
  questionnaire,
  questions,
  onComplete
}: QuestionnaireFormProps) {
  const { user } = useAuth();
  const { toast } = useToast();
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [completed, setCompleted] = useState(false);

  const currentQuestion = questions[currentQuestionIndex];
  const progress = (currentQuestionIndex / questions.length) * 100;
  const isFirstQuestion = currentQuestionIndex === 0;
  const isLastQuestion = currentQuestionIndex === questions.length - 1;
  
  const { mutate: submitQuestionnaire, isPending } = useMutation({
    mutationFn: async (data: { 
      userId: number, 
      type: string, 
      score: number, 
      answers: Record<number, number>,
      completed: boolean
    }) => {
      const res = await apiRequest('POST', '/api/assessments', data);
      return await res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/assessments/latest'] });
      toast({
        title: 'Assessment completed',
        description: 'Your responses have been saved successfully.',
      });
    },
    onError: (error) => {
      toast({
        title: 'Submission failed',
        description: error.message,
        variant: 'destructive',
      });
    }
  });

  const handleAnswer = (value: number) => {
    const updatedAnswers = { ...answers };
    updatedAnswers[currentQuestion.id] = value;
    setAnswers(updatedAnswers);
    
    if (isLastQuestion) {
      completeQuestionnaire(updatedAnswers);
    } else {
      setCurrentQuestionIndex(currentQuestionIndex + 1);
    }
  };

  const handlePrevious = () => {
    if (!isFirstQuestion) {
      setCurrentQuestionIndex(currentQuestionIndex - 1);
    }
  };

  const calculateScore = (answerObj: Record<number, number>): number => {
    return Object.values(answerObj).reduce((total, value) => total + value, 0);
  };

  const completeQuestionnaire = (finalAnswers: Record<number, number>) => {
    const score = calculateScore(finalAnswers);
    setCompleted(true);
    
    if (user) {
      submitQuestionnaire({
        userId: user.id,
        type: questionnaire,
        score,
        answers: finalAnswers,
        completed: true
      });
    }
    
    if (onComplete) {
      onComplete(score, finalAnswers);
    }
  };

  const getInterpretation = (score: number) => {
    return questionnaire === 'epds' 
      ? getEpdsInterpretation(score) 
      : getPhq9Interpretation(score);
  };

  const resetQuestionnaire = () => {
    setAnswers({});
    setCurrentQuestionIndex(0);
    setCompleted(false);
  };

  const renderSuicideRiskAlert = () => {
    // Question 10 for EPDS or Question 9 for PHQ-9 checks for suicidal thoughts
    const suicidalQuestionId = questionnaire === 'epds' ? 10 : 9;
    const suicidalAnswer = answers[suicidalQuestionId];
    
    if (suicidalAnswer && suicidalAnswer > 0) {
      return (
        <Alert variant="destructive" className="mb-6">
          <AlertTriangle className="h-5 w-5" />
          <AlertTitle>Important Notice</AlertTitle>
          <AlertDescription>
            Your responses indicate you may be having thoughts about harming yourself. 
            Please contact a healthcare professional immediately or call a mental health helpline.
          </AlertDescription>
        </Alert>
      );
    }
    return null;
  };

  if (completed) {
    const score = calculateScore(answers);
    const interpretation = getInterpretation(score);
    
    return (
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-center">Assessment Results</CardTitle>
          <CardDescription className="text-center">
            Thank you for completing the assessment
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {renderSuicideRiskAlert()}
          
          <div className="flex justify-center items-center flex-col">
            <div className="text-7xl font-bold mb-2">{score}</div>
            <div className="text-muted-foreground">Total Score</div>
          </div>
          
          <div className="bg-muted p-4 rounded-lg">
            <div className="flex items-center gap-2 mb-2">
              <div className={`w-3 h-3 rounded-full ${interpretation.color}`}></div>
              <h3 className="font-medium">{interpretation.severity} Risk</h3>
            </div>
            <p className="text-sm text-muted-foreground">
              {interpretation.description}
            </p>
          </div>
          
          <div className="text-sm text-muted-foreground">
            <p className="mb-2"><strong>Next steps:</strong></p>
            <ul className="list-disc pl-5 space-y-1">
              <li>Review your personalized care plan recommendations</li>
              <li>Track your mood regularly</li>
              <li>Speak with a healthcare provider about your results</li>
              <li>Retake this assessment in 2-4 weeks to monitor changes</li>
            </ul>
          </div>
        </CardContent>
        <CardFooter className="flex justify-between">
          <Button variant="outline" onClick={resetQuestionnaire}>
            Start Over
          </Button>
          <Button>
            View Care Plan
          </Button>
        </CardFooter>
      </Card>
    );
  }

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        <CardDescription>{description}</CardDescription>
        <Progress value={progress} className="h-2 mt-2" />
      </CardHeader>
      <CardContent>
        <div className="mb-6">
          <div className="text-sm text-muted-foreground mb-1">
            Question {currentQuestionIndex + 1} of {questions.length}
          </div>
          <h3 className="text-lg font-medium mb-4">{currentQuestion.question}</h3>
          
          <RadioGroup className="space-y-3">
            {currentQuestion.options.map((option) => (
              <div key={option.value} className="flex items-center space-x-2">
                <RadioGroupItem 
                  id={`q${currentQuestion.id}-option-${option.value}`} 
                  value={option.value.toString()} 
                  className="peer"
                  onClick={() => handleAnswer(option.value)}
                />
                <Label 
                  htmlFor={`q${currentQuestion.id}-option-${option.value}`}
                  className="cursor-pointer flex-1 text-sm py-2"
                >
                  {option.label}
                </Label>
              </div>
            ))}
          </RadioGroup>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button 
          variant="outline" 
          onClick={handlePrevious}
          disabled={isFirstQuestion}
        >
          <ArrowLeft className="mr-2 h-4 w-4" />
          Previous
        </Button>
        {isLastQuestion ? (
          <Button 
            onClick={() => completeQuestionnaire(answers)}
            disabled={isPending || !answers[currentQuestion.id]}
          >
            <CheckCircle2 className="mr-2 h-4 w-4" />
            Complete
          </Button>
        ) : (
          <Button 
            variant="ghost" 
            className="ml-auto"
            disabled={!answers[currentQuestion.id]}
          >
            Select an option to continue
            <ArrowRight className="ml-2 h-4 w-4" />
          </Button>
        )}
      </CardFooter>
    </Card>
  );
}