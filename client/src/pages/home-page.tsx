import { AppLayout } from "@/components/app-layout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { MoodTracker } from "@/components/mood-tracker";
import { useAuth } from "@/hooks/use-auth";
import { useQuery } from "@tanstack/react-query";
import { useLocation } from "wouter";
import { HeartPulse, BookOpen, MessageSquareHeart, Users, AlertTriangle, Phone } from "lucide-react";
import { format, formatDistanceToNow } from "date-fns";

export default function HomePage() {
  const { user } = useAuth();
  const [, navigate] = useLocation();

  // Fetch the latest assessment
  const { data: assessment, isLoading: assessmentLoading } = useQuery({
    queryKey: ["/api/assessments/latest"],
    queryFn: async () => {
      try {
        const response = await fetch("/api/assessments/latest");
        if (!response.ok) {
          if (response.status === 404) {
            return null;
          }
          throw new Error("Failed to fetch assessment");
        }
        return await response.json();
      } catch (error) {
        console.error("Error fetching assessment:", error);
        return null;
      }
    }
  });

  // Fetch daily wellness tip (static data for now)
  const dailyTip = {
    content: "Take 5 minutes to sit quietly and focus on your breath. Self-care doesn't always need to be elaborate."
  };

  const firstName = user?.fullName?.split(' ')[0] || 'there';
  const lastAssessmentDate = assessment ? new Date(assessment.date) : null;

  return (
    <AppLayout>
      <div className="bg-primary text-white px-4 py-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="font-bold text-2xl">Welcome, {firstName}</h1>
            <p className="text-primary-light text-sm mt-1">How are you feeling today?</p>
          </div>
        </div>
        
        {/* Mood Tracker */}
        <div className="mt-6 bg-white bg-opacity-10 rounded-xl p-4">
          <h2 className="font-medium text-sm mb-3">Today's Mood</h2>
          <MoodTracker />
        </div>
      </div>
      
      {/* Main Content */}
      <div className="px-4 py-6">
        {/* Assessment Card */}
        <Card className="mb-6">
          <CardHeader className="pb-2">
            <div className="flex items-center justify-between">
              <CardTitle>Wellness Check-In</CardTitle>
              <span className="text-xs text-muted-foreground">5 min</span>
            </div>
            <CardDescription>
              Regular check-ins help track your mood patterns and provide personalized support.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Progress 
              value={lastAssessmentDate ? 60 : 0} 
              className="h-2 mb-3" 
            />
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">
                Last check-in: {lastAssessmentDate 
                  ? formatDistanceToNow(lastAssessmentDate, { addSuffix: true }) 
                  : 'None yet'}
              </span>
            </div>
          </CardContent>
          <CardFooter>
            <Button 
              className="w-full sm:w-auto ml-auto" 
              onClick={() => navigate('/assessment')}
            >
              Start Check-In
            </Button>
          </CardFooter>
        </Card>
        
        {/* Action Cards Grid */}
        <div className="grid grid-cols-2 gap-4 mb-6">
          {/* Self Care Plan */}
          <Card className="cursor-pointer hover:shadow-md transition-shadow" onClick={() => navigate('/care-plan')}>
            <CardContent className="p-4">
              <div className="w-10 h-10 bg-accent bg-opacity-20 rounded-lg flex items-center justify-center mb-3">
                <HeartPulse className="text-accent h-5 w-5" />
              </div>
              <h3 className="font-semibold text-base mb-1">Your Plan</h3>
              <p className="text-xs text-muted-foreground">Personalized self-care plan</p>
            </CardContent>
          </Card>
          
          {/* Resources */}
          <Card className="cursor-pointer hover:shadow-md transition-shadow" onClick={() => navigate('/resources')}>
            <CardContent className="p-4">
              <div className="w-10 h-10 bg-secondary bg-opacity-20 rounded-lg flex items-center justify-center mb-3">
                <BookOpen className="text-secondary h-5 w-5" />
              </div>
              <h3 className="font-semibold text-base mb-1">Resources</h3>
              <p className="text-xs text-muted-foreground">Articles, tips & guidance</p>
            </CardContent>
          </Card>
          
          {/* Support Chat */}
          <Card className="cursor-pointer hover:shadow-md transition-shadow">
            <CardContent className="p-4">
              <div className="w-10 h-10 bg-success bg-opacity-20 rounded-lg flex items-center justify-center mb-3">
                <MessageSquareHeart className="text-success h-5 w-5" />
              </div>
              <h3 className="font-semibold text-base mb-1">Support Chat</h3>
              <p className="text-xs text-muted-foreground">Connect with care providers</p>
            </CardContent>
          </Card>
          
          {/* Community */}
          <Card className="cursor-pointer hover:shadow-md transition-shadow">
            <CardContent className="p-4">
              <div className="w-10 h-10 bg-primary bg-opacity-20 rounded-lg flex items-center justify-center mb-3">
                <Users className="text-primary h-5 w-5" />
              </div>
              <h3 className="font-semibold text-base mb-1">Community</h3>
              <p className="text-xs text-muted-foreground">Connect with other mothers</p>
            </CardContent>
          </Card>
        </div>
        
        {/* Daily Tip */}
        <Alert className="bg-accent bg-opacity-10 border-accent mb-6">
          <CardTitle className="text-sm font-semibold text-accent-dark mb-2">Daily Wellness Tip</CardTitle>
          <AlertDescription className="text-sm text-neutral-700">
            {dailyTip.content}
          </AlertDescription>
        </Alert>
        
        {/* Emergency Support */}
        <Alert className="bg-destructive bg-opacity-10 border-destructive border">
          <div className="flex items-start gap-2">
            <AlertTriangle className="h-5 w-5 text-destructive mt-0.5" />
            <div>
              <AlertTitle className="text-destructive font-semibold mb-2">Need Immediate Support?</AlertTitle>
              <AlertDescription className="text-sm text-neutral-700 mb-3">
                If you're experiencing severe distress or having thoughts of harming yourself, please reach out immediately.
              </AlertDescription>
              <Button variant="destructive" className="w-full flex items-center justify-center gap-2">
                <Phone className="h-4 w-4" />
                Call Support Line
              </Button>
            </div>
          </div>
        </Alert>
      </div>
    </AppLayout>
  );
}
