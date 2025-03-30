import { useState } from "react";
import { useLocation } from "wouter";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Progress } from "@/components/ui/progress";
import { ArrowLeft, CheckCircle, ArrowRightCircle, ClipboardCheck, Brain, Check } from "lucide-react";
import { QuestionnaireForm } from "@/components/questionnaire-form";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useAuth } from "@/hooks/use-auth";
import { epdsQuestions, phq9Questions, getEpdsInterpretation, getPhq9Interpretation } from "@/lib/assessmentData";

interface AssessmentResult {
  id: number;
  score: number;
  type: string;
  date: string;
}

export default function AssessmentPage() {
  const [, navigate] = useLocation();
  const { user } = useAuth();
  const [activeQuestionnaireType, setActiveQuestionnaireType] = useState<"epds" | "phq9">("epds");
  const [showHistory, setShowHistory] = useState(false);

  // Fetch assessment history
  const { data: assessmentHistory, isLoading: isHistoryLoading } = useQuery({
    queryKey: ['/api/assessments/history'],
    queryFn: async () => {
      try {
        const response = await fetch('/api/assessments/history');
        if (!response.ok) {
          return [];
        }
        return await response.json();
      } catch (error) {
        console.error('Error fetching assessment history:', error);
        return [];
      }
    }
  });

  // Handler for assessment completion
  const handleAssessmentComplete = (score: number, answers: Record<number, number>) => {
    // Navigate to care plan page after assessment is complete
    setTimeout(() => {
      navigate('/care-plan');
    }, 5000);
  };

  return (
    <div className="min-h-screen bg-background">
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
          <h1 className="font-bold text-xl">Mental Health Assessment</h1>
        </div>
      </div>
      
      <div className="px-4 py-6">
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Choose Your Assessment</CardTitle>
            <CardDescription>
              Complete one of these validated questionnaires to assess your mental health.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="assessments" className="w-full">
              <TabsList className="grid w-full grid-cols-2 mb-4">
                <TabsTrigger value="assessments">Assessments</TabsTrigger>
                <TabsTrigger value="history">History</TabsTrigger>
              </TabsList>

              <TabsContent value="assessments">
                <Tabs defaultValue={activeQuestionnaireType} onValueChange={(value) => setActiveQuestionnaireType(value as "epds" | "phq9")}>
                  <TabsList className="grid w-full grid-cols-2 mb-6">
                    <TabsTrigger value="epds" className="flex items-center gap-2">
                      <ClipboardCheck className="h-4 w-4" />
                      <span>EPDS</span>
                    </TabsTrigger>
                    <TabsTrigger value="phq9" className="flex items-center gap-2">
                      <Brain className="h-4 w-4" />
                      <span>PHQ-9</span>
                    </TabsTrigger>
                  </TabsList>

                  <TabsContent value="epds">
                    <div className="mb-6">
                      <h3 className="text-lg font-semibold mb-2">Edinburgh Postnatal Depression Scale</h3>
                      <p className="text-sm text-muted-foreground mb-4">
                        This 10-question self-assessment tool helps identify symptoms of depression during pregnancy and after childbirth.
                      </p>
                      
                      <div className="grid grid-cols-2 gap-4 mb-6">
                        <div className="bg-muted p-3 rounded-lg">
                          <p className="text-sm font-medium">Time to complete</p>
                          <p className="text-sm text-muted-foreground">5 minutes</p>
                        </div>
                        <div className="bg-muted p-3 rounded-lg">
                          <p className="text-sm font-medium">Recommended</p>
                          <p className="text-sm text-muted-foreground">Every 2-4 weeks</p>
                        </div>
                      </div>

                      <QuestionnaireForm
                        title="Edinburgh Postnatal Depression Scale (EPDS)"
                        description="Please select the answer that comes closest to how you have felt in the past 7 days, not just how you feel today."
                        questionnaire="epds"
                        questions={epdsQuestions}
                        onComplete={handleAssessmentComplete}
                      />
                    </div>
                  </TabsContent>

                  <TabsContent value="phq9">
                    <div className="mb-6">
                      <h3 className="text-lg font-semibold mb-2">Patient Health Questionnaire (PHQ-9)</h3>
                      <p className="text-sm text-muted-foreground mb-4">
                        This 9-question tool is used to assess the severity of depression symptoms over the last two weeks.
                      </p>
                      
                      <div className="grid grid-cols-2 gap-4 mb-6">
                        <div className="bg-muted p-3 rounded-lg">
                          <p className="text-sm font-medium">Time to complete</p>
                          <p className="text-sm text-muted-foreground">3-5 minutes</p>
                        </div>
                        <div className="bg-muted p-3 rounded-lg">
                          <p className="text-sm font-medium">Recommended</p>
                          <p className="text-sm text-muted-foreground">Monthly</p>
                        </div>
                      </div>

                      <QuestionnaireForm
                        title="Patient Health Questionnaire (PHQ-9)"
                        description="Over the last 2 weeks, how often have you been bothered by any of the following problems?"
                        questionnaire="phq9"
                        questions={phq9Questions}
                        onComplete={handleAssessmentComplete}
                      />
                    </div>
                  </TabsContent>
                </Tabs>
              </TabsContent>

              <TabsContent value="history">
                <div>
                  <h3 className="font-semibold text-lg mb-4">Your Assessment History</h3>
                  
                  {isHistoryLoading ? (
                    <div className="flex justify-center py-8">
                      <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-primary"></div>
                    </div>
                  ) : assessmentHistory && assessmentHistory.length > 0 ? (
                    <div className="space-y-4">
                      {assessmentHistory.map((assessment: AssessmentResult) => {
                        const date = new Date(assessment.date);
                        const formattedDate = date.toLocaleDateString('en-US', { 
                          year: 'numeric', 
                          month: 'short', 
                          day: 'numeric' 
                        });
                        
                        const interpretation = assessment.type === 'epds' 
                          ? getEpdsInterpretation(assessment.score)
                          : getPhq9Interpretation(assessment.score);
                          
                        return (
                          <div key={assessment.id} className="border rounded-lg p-4">
                            <div className="flex justify-between items-start mb-3">
                              <div>
                                <h4 className="font-medium">{assessment.type === 'epds' ? 'EPDS' : 'PHQ-9'} Assessment</h4>
                                <p className="text-sm text-muted-foreground">{formattedDate}</p>
                              </div>
                              <div className="flex items-center">
                                <div className={`w-3 h-3 rounded-full ${interpretation.color} mr-2`}></div>
                                <span className="text-sm font-medium">{assessment.score}</span>
                              </div>
                            </div>
                            <div className="bg-muted p-3 rounded-lg text-sm">
                              <p className="font-medium">{interpretation.severity}</p>
                              <p className="text-muted-foreground">{interpretation.description}</p>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  ) : (
                    <div className="text-center py-8">
                      <p className="text-muted-foreground mb-4">You haven't completed any assessments yet.</p>
                      <Button onClick={() => setShowHistory(false)}>Take Your First Assessment</Button>
                    </div>
                  )}
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
