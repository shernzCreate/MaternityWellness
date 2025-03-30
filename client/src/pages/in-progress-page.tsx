import React, { useState } from "react";
import { AppLayout } from "@/components/app-layout";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Separator } from "@/components/ui/separator";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { useToast } from "@/hooks/use-toast";
import {
  Calendar,
  Clock,
  Code,
  ExternalLink,
  Heart,
  HelpCircle,
  Lightbulb,
  MessageSquare,
  Sparkles,
  SquareStack,
  ThumbsUp,
  Timer,
  Users,
  Video,
  File,
  ClipboardList,
  BarChart,
  Bell,
  CloudSnow,
  MapPin,
  ChartLine,
  BrainCircuit
} from "lucide-react";

interface FeatureItem {
  id: number;
  title: string;
  description: string;
  category: "community" | "assessment" | "resources" | "care";
  priority: "high" | "medium" | "low";
  status: "planned" | "in-progress" | "testing";
  progress: number;
  eta: string;
}

interface FeedbackItem {
  id: number;
  feature: string;
  description: string;
  status: "submitted" | "reviewing" | "implemented";
  date: string;
}

export default function InProgressPage() {
  const { toast } = useToast();
  const [feedbackFormOpen, setFeedbackFormOpen] = useState(false);
  const [feedbackText, setFeedbackText] = useState("");
  const [selectedFeature, setSelectedFeature] = useState<string>("");

  // Feature roadmap data
  const features: FeatureItem[] = [
    {
      id: 1,
      title: "Support Groups",
      description: "Virtual support groups led by mental health professionals and experienced mothers",
      category: "community",
      priority: "high",
      status: "in-progress",
      progress: 65,
      eta: "2023-06-15"
    },
    {
      id: 2,
      title: "Partner/Family Support Module",
      description: "Resources and tools specifically for partners and family members to understand PPD",
      category: "resources",
      priority: "medium",
      status: "in-progress",
      progress: 40,
      eta: "2023-07-01"
    },
    {
      id: 3,
      title: "Care Journal",
      description: "Daily journal for tracking thoughts, feelings, and self-care activities",
      category: "care",
      priority: "high",
      status: "testing",
      progress: 85,
      eta: "2023-06-01"
    },
    {
      id: 4,
      title: "Crisis Support Hotline Integration",
      description: "Direct connection to Singapore crisis support hotlines",
      category: "community",
      priority: "high",
      status: "planned",
      progress: 10,
      eta: "2023-07-15"
    },
    {
      id: 5,
      title: "Advanced Progress Tracking",
      description: "Enhanced visualization of assessment results and progress over time",
      category: "assessment",
      priority: "medium",
      status: "in-progress",
      progress: 50,
      eta: "2023-06-30"
    },
    {
      id: 6,
      title: "Appointment Scheduling",
      description: "Book appointments with healthcare providers directly through the app",
      category: "care",
      priority: "medium",
      status: "planned",
      progress: 20,
      eta: "2023-08-01"
    },
    {
      id: 7,
      title: "Guided Meditation Library",
      description: "Audio-guided meditations specifically for postpartum anxiety and depression",
      category: "resources",
      priority: "low",
      status: "in-progress",
      progress: 30,
      eta: "2023-07-15"
    },
    {
      id: 8, 
      title: "Local Resource Finder",
      description: "Map-based tool to find nearby mental health resources in Singapore",
      category: "resources",
      priority: "high",
      status: "testing",
      progress: 90,
      eta: "2023-05-30"
    }
  ];

  // User feedback data
  const feedbackItems: FeedbackItem[] = [
    {
      id: 1,
      feature: "Audio Resources",
      description: "Would love to see audio versions of the articles for when I'm nursing",
      status: "implemented",
      date: "2023-04-10"
    },
    {
      id: 2,
      feature: "Multilingual Support",
      description: "Please add content in Mandarin and Malay for non-English speaking mothers",
      status: "reviewing",
      date: "2023-04-25"
    },
    {
      id: 3,
      feature: "Baby Milestone Tracker",
      description: "It would be helpful to track baby's milestones alongside my mental health",
      status: "submitted",
      date: "2023-05-02"
    }
  ];

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('en-SG', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    }).format(date);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "planned":
        return "text-blue-500 bg-blue-50";
      case "in-progress":
        return "text-amber-500 bg-amber-50";
      case "testing":
        return "text-green-500 bg-green-50";
      case "implemented":
        return "text-green-500 bg-green-50";
      case "reviewing":
        return "text-purple-500 bg-purple-50";
      case "submitted":
        return "text-gray-500 bg-gray-50";
      default:
        return "text-gray-500 bg-gray-50";
    }
  };

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case "community":
        return <Users className="w-5 h-5" />;
      case "assessment":
        return <ClipboardList className="w-5 h-5" />;
      case "resources":
        return <File className="w-5 h-5" />;
      case "care":
        return <Heart className="w-5 h-5" />;
      default:
        return <Sparkles className="w-5 h-5" />;
    }
  };

  const getProgressColor = (progress: number) => {
    if (progress < 30) return "bg-blue-500";
    if (progress < 70) return "bg-amber-500";
    return "bg-green-500";
  };

  const submitFeedback = () => {
    if (!feedbackText.trim()) {
      toast({
        title: "Error",
        description: "Please enter your feedback",
        variant: "destructive",
      });
      return;
    }

    // In a real app, this would call an API
    toast({
      title: "Feedback Submitted",
      description: "Thank you for your feedback! We'll review it soon.",
    });
    
    setFeedbackText("");
    setFeedbackFormOpen(false);
  };

  return (
    <AppLayout>
      <div className="container py-6 max-w-4xl">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold">Development Roadmap</h1>
            <p className="text-muted-foreground mt-1">
              Track the progress of upcoming features and improvements
            </p>
          </div>
          <Button 
            className="mt-4 md:mt-0"
            onClick={() => setFeedbackFormOpen(true)}
          >
            <Lightbulb className="w-4 h-4 mr-2" />
            Suggest a Feature
          </Button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Sidebar */}
          <div className="lg:col-span-1">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Development Status</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div>
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-sm font-medium">Overall Progress</span>
                      <span className="text-sm text-muted-foreground">48%</span>
                    </div>
                    <Progress value={48} className="h-2" />
                  </div>
                  
                  <Separator />
                  
                  <div className="space-y-3">
                    <div className="flex justify-between items-center">
                      <div className="flex items-center">
                        <div className="w-3 h-3 rounded-full bg-gray-200 mr-2"></div>
                        <span className="text-sm">Planned</span>
                      </div>
                      <Badge variant="outline">{features.filter(f => f.status === 'planned').length}</Badge>
                    </div>
                    <div className="flex justify-between items-center">
                      <div className="flex items-center">
                        <div className="w-3 h-3 rounded-full bg-amber-500 mr-2"></div>
                        <span className="text-sm">In Progress</span>
                      </div>
                      <Badge variant="outline">{features.filter(f => f.status === 'in-progress').length}</Badge>
                    </div>
                    <div className="flex justify-between items-center">
                      <div className="flex items-center">
                        <div className="w-3 h-3 rounded-full bg-green-500 mr-2"></div>
                        <span className="text-sm">Testing</span>
                      </div>
                      <Badge variant="outline">{features.filter(f => f.status === 'testing').length}</Badge>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div className="space-y-3">
                    <h4 className="text-sm font-medium">Feature Categories</h4>
                    <div className="grid grid-cols-2 gap-2">
                      <Button variant="outline" size="sm" className="justify-start h-auto py-2">
                        <Users className="w-4 h-4 mr-2 text-primary" />
                        <span className="text-xs">Community</span>
                      </Button>
                      <Button variant="outline" size="sm" className="justify-start h-auto py-2">
                        <ClipboardList className="w-4 h-4 mr-2 text-primary" />
                        <span className="text-xs">Assessment</span>
                      </Button>
                      <Button variant="outline" size="sm" className="justify-start h-auto py-2">
                        <File className="w-4 h-4 mr-2 text-primary" />
                        <span className="text-xs">Resources</span>
                      </Button>
                      <Button variant="outline" size="sm" className="justify-start h-auto py-2">
                        <Heart className="w-4 h-4 mr-2 text-primary" />
                        <span className="text-xs">Care</span>
                      </Button>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
            
            <Card className="mt-6">
              <CardHeader>
                <CardTitle className="text-lg">Coming Next</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {features
                    .filter(f => f.status === 'testing')
                    .slice(0, 2)
                    .map(feature => (
                      <div key={feature.id} className="bg-accent/10 p-3 rounded-lg">
                        <div className="flex items-center">
                          <div className="p-2 rounded-full bg-accent/20 mr-2">
                            {getCategoryIcon(feature.category)}
                          </div>
                          <div>
                            <h4 className="font-medium text-sm">{feature.title}</h4>
                            <div className="flex items-center mt-1">
                              <Calendar className="w-3 h-3 mr-1 text-muted-foreground" />
                              <span className="text-xs text-muted-foreground">
                                Expected: {formatDate(feature.eta)}
                              </span>
                            </div>
                          </div>
                        </div>
                        <Progress 
                          value={feature.progress} 
                          className={`h-1.5 mt-3 ${getProgressColor(feature.progress)}`} 
                        />
                      </div>
                    ))
                  }
                </div>
              </CardContent>
            </Card>
          </div>
          
          {/* Main Content */}
          <div className="lg:col-span-3">
            <Tabs defaultValue="roadmap">
              <TabsList className="grid w-full grid-cols-2 mb-6">
                <TabsTrigger value="roadmap" className="flex items-center">
                  <SquareStack className="w-4 h-4 mr-2" />
                  Feature Roadmap
                </TabsTrigger>
                <TabsTrigger value="feedback" className="flex items-center">
                  <MessageSquare className="w-4 h-4 mr-2" />
                  Community Feedback
                </TabsTrigger>
              </TabsList>
              
              <TabsContent value="roadmap">
                <Card>
                  <CardHeader>
                    <CardTitle>All Upcoming Features</CardTitle>
                    <CardDescription>
                      Track the progress of features currently in development
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-6">
                      {features.map(feature => (
                        <div key={feature.id} className="bg-card border rounded-lg overflow-hidden">
                          <div className="p-4">
                            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                              <div className="flex items-start">
                                <div className={`p-2 rounded-full mr-3 bg-${feature.category === 'community' ? 'purple' : feature.category === 'assessment' ? 'blue' : feature.category === 'resources' ? 'amber' : 'pink'}-100`}>
                                  {getCategoryIcon(feature.category)}
                                </div>
                                <div>
                                  <h3 className="font-medium">{feature.title}</h3>
                                  <p className="text-sm text-muted-foreground mt-1">
                                    {feature.description}
                                  </p>
                                </div>
                              </div>
                              <div className="flex items-center gap-2 md:self-start">
                                <Badge className={getStatusColor(feature.status)}>
                                  {feature.status}
                                </Badge>
                                <Badge variant={feature.priority === 'high' ? 'destructive' : feature.priority === 'medium' ? 'secondary' : 'outline'}>
                                  {feature.priority}
                                </Badge>
                              </div>
                            </div>
                            
                            <div className="mt-4">
                              <div className="flex items-center justify-between mb-1">
                                <span className="text-xs font-medium">Progress</span>
                                <span className="text-xs text-muted-foreground">{feature.progress}%</span>
                              </div>
                              <Progress 
                                value={feature.progress} 
                                className={`h-2 ${getProgressColor(feature.progress)}`} 
                              />
                            </div>
                            
                            <div className="flex items-center justify-between mt-4">
                              <div className="flex items-center">
                                <Clock className="w-4 h-4 mr-1 text-muted-foreground" />
                                <span className="text-xs text-muted-foreground">
                                  Expected: {formatDate(feature.eta)}
                                </span>
                              </div>
                              <Button variant="ghost" size="sm">
                                <ThumbsUp className="w-4 h-4 mr-1" />
                                <span className="text-xs">Support this</span>
                              </Button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
                
                <Card className="mt-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Future Concepts</CardTitle>
                    <CardDescription>
                      Features we're researching for future development
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="border p-4 rounded-lg">
                        <div className="flex items-center mb-3">
                          <div className="p-2 rounded-full bg-accent/20 mr-2">
                            <Video className="w-4 h-4 text-accent" />
                          </div>
                          <h4 className="font-medium">Video Therapy Sessions</h4>
                        </div>
                        <p className="text-sm text-muted-foreground">
                          Secure video therapy sessions with licensed therapists specializing in postpartum care
                        </p>
                      </div>
                      
                      <div className="border p-4 rounded-lg">
                        <div className="flex items-center mb-3">
                          <div className="p-2 rounded-full bg-accent/20 mr-2">
                            <BrainCircuit className="w-4 h-4 text-accent" />
                          </div>
                          <h4 className="font-medium">AI Mood Analysis</h4>
                        </div>
                        <p className="text-sm text-muted-foreground">
                          Advanced analysis of mood patterns to provide personalized insights and recommendations
                        </p>
                      </div>
                      
                      <div className="border p-4 rounded-lg">
                        <div className="flex items-center mb-3">
                          <div className="p-2 rounded-full bg-accent/20 mr-2">
                            <ChartLine className="w-4 h-4 text-accent" />
                          </div>
                          <h4 className="font-medium">Personalized Reports</h4>
                        </div>
                        <p className="text-sm text-muted-foreground">
                          Downloadable reports to share with healthcare providers to better coordinate care
                        </p>
                      </div>
                      
                      <div className="border p-4 rounded-lg">
                        <div className="flex items-center mb-3">
                          <div className="p-2 rounded-full bg-accent/20 mr-2">
                            <Bell className="w-4 h-4 text-accent" />
                          </div>
                          <h4 className="font-medium">Smart Notifications</h4>
                        </div>
                        <p className="text-sm text-muted-foreground">
                          Context-aware reminders and notifications based on your care plan and mood patterns
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
              
              <TabsContent value="feedback">
                <Card>
                  <CardHeader>
                    <CardTitle>Community Feedback</CardTitle>
                    <CardDescription>
                      See what others have suggested and submit your own ideas
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    {feedbackFormOpen ? (
                      <div className="bg-accent/10 border-accent p-4 rounded-lg mb-6">
                        <h3 className="font-medium mb-3">Suggest a Feature</h3>
                        <div className="space-y-4">
                          <div>
                            <label className="block text-sm font-medium mb-1">Feature Type</label>
                            <select 
                              className="w-full p-2 border rounded-md bg-background"
                              value={selectedFeature}
                              onChange={(e) => setSelectedFeature(e.target.value)}
                            >
                              <option value="">Select a feature type</option>
                              <option value="Community Features">Community Features</option>
                              <option value="Assessment Tools">Assessment Tools</option>
                              <option value="Educational Resources">Educational Resources</option>
                              <option value="Care Plan">Care Plan</option>
                              <option value="User Interface">User Interface</option>
                              <option value="Other">Other</option>
                            </select>
                          </div>
                          <div>
                            <label className="block text-sm font-medium mb-1">Your Suggestion</label>
                            <textarea 
                              className="w-full p-3 border rounded-md bg-background min-h-[100px]"
                              placeholder="Describe the feature you'd like to see..."
                              value={feedbackText}
                              onChange={(e) => setFeedbackText(e.target.value)}
                            ></textarea>
                          </div>
                          <div className="flex justify-end gap-2">
                            <Button 
                              variant="outline" 
                              onClick={() => setFeedbackFormOpen(false)}
                            >
                              Cancel
                            </Button>
                            <Button onClick={submitFeedback}>
                              Submit Feedback
                            </Button>
                          </div>
                        </div>
                      </div>
                    ) : (
                      <Button 
                        variant="outline" 
                        className="w-full mb-6"
                        onClick={() => setFeedbackFormOpen(true)}
                      >
                        <Lightbulb className="w-4 h-4 mr-2" />
                        Suggest a New Feature
                      </Button>
                    )}
                    
                    <div className="space-y-4">
                      {feedbackItems.map(item => (
                        <div key={item.id} className="border p-4 rounded-lg">
                          <div className="flex justify-between items-start">
                            <h4 className="font-medium">{item.feature}</h4>
                            <Badge className={getStatusColor(item.status)}>
                              {item.status}
                            </Badge>
                          </div>
                          <p className="text-sm text-muted-foreground mt-2">
                            {item.description}
                          </p>
                          <div className="flex items-center mt-3">
                            <Clock className="w-4 h-4 mr-1 text-muted-foreground" />
                            <span className="text-xs text-muted-foreground">
                              Submitted on {formatDate(item.date)}
                            </span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
                
                <Alert className="mt-6">
                  <HelpCircle className="w-4 h-4" />
                  <AlertTitle>How are features prioritized?</AlertTitle>
                  <AlertDescription>
                    We prioritize features based on clinical value, user feedback, technical feasibility, and alignment with our mission to support maternal mental health in Singapore.
                  </AlertDescription>
                </Alert>
                
                <Card className="mt-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Get Involved</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm text-muted-foreground mb-4">
                      Want to help shape the future of this app? Here's how you can get involved:
                    </p>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <Button variant="outline" className="flex items-center justify-center h-auto py-3">
                        <MessageSquare className="w-4 h-4 mr-2" />
                        Join User Research Panel
                      </Button>
                      <Button variant="outline" className="flex items-center justify-center h-auto py-3">
                        <ExternalLink className="w-4 h-4 mr-2" />
                        Participate in Beta Testing
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
            </Tabs>
          </div>
        </div>
      </div>
    </AppLayout>
  );
}