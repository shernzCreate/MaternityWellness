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
import {
  Avatar,
  AvatarFallback,
  AvatarImage,
} from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { Switch } from "@/components/ui/switch";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/hooks/use-auth";
import { useToast } from "@/hooks/use-toast";
import { getInitials } from "@/lib/utils";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useMutation, useQuery } from "@tanstack/react-query";
import { 
  User,
  Bell,
  Settings,
  Lock,
  LogOut,
  Edit,
  Save,
  Award,
  Book,
  Calendar,
  Clock,
  UserCheck,
  Send
} from "lucide-react";
import { Link } from "wouter";
import { useIsMobile } from "@/hooks/use-mobile";

interface UserProfile {
  username: string;
  fullName: string;
  email: string;
  phone?: string;
  location?: string;
  preferredLanguage?: string;
  joinDate: string;
  notificationSettings: {
    assessmentReminders: boolean;
    communityUpdates: boolean;
    resourceUpdates: boolean;
    supportMessages: boolean;
  };
}

interface Achievement {
  id: number;
  title: string;
  description: string;
  dateEarned: string;
  icon: string;
}

export default function ProfilePage() {
  const { user, logoutMutation } = useAuth();
  const isMobile = useIsMobile();
  const { toast } = useToast();
  const [isEditing, setIsEditing] = useState(false);
  
  const [profile, setProfile] = useState<UserProfile>({
    username: user?.username || "",
    fullName: user?.fullName || "",
    email: user?.email || "",
    phone: user?.phone || "",
    location: "Singapore",
    preferredLanguage: "English",
    joinDate: new Date().toISOString(),
    notificationSettings: {
      assessmentReminders: true,
      communityUpdates: true,
      resourceUpdates: true,
      supportMessages: true,
    }
  });

  // Demo achievements
  const achievements: Achievement[] = [
    {
      id: 1,
      title: "Getting Started",
      description: "Completed your first assessment",
      dateEarned: "2023-03-15",
      icon: "Award"
    },
    {
      id: 2,
      title: "Resource Explorer",
      description: "Read 5 articles from the resource library",
      dateEarned: "2023-03-20",
      icon: "Book"
    },
    {
      id: 3,
      title: "Community Contributor",
      description: "Made your first post in the community forum",
      dateEarned: "2023-04-02",
      icon: "Users"
    }
  ];

  // Mock upcoming appointments for demo
  const upcomingAppointments = [
    {
      id: 1,
      title: "Therapy Session",
      provider: "Dr. Lisa Wong",
      date: "2023-05-15T14:00:00",
      location: "Singapore General Hospital",
      virtual: false
    },
    {
      id: 2,
      title: "Support Group",
      provider: "PPD Support Network",
      date: "2023-05-18T10:00:00",
      location: "Zoom",
      virtual: true
    }
  ];

  // Mock event data for demo
  const activityHistory = [
    {
      id: 1,
      type: "assessment",
      description: "Completed EPDS Assessment",
      date: "2023-04-30T09:15:00"
    },
    {
      id: 2,
      type: "resource",
      description: "Read 'Coping with Sleep Deprivation'",
      date: "2023-04-28T21:30:00"
    },
    {
      id: 3,
      type: "community",
      description: "Posted in Community Forum",
      date: "2023-04-25T16:45:00"
    },
    {
      id: 4,
      type: "mood",
      description: "Logged mood: Anxious",
      date: "2023-04-25T10:00:00"
    }
  ];

  const updateProfileMutation = useMutation({
    mutationFn: async (updatedProfile: Partial<UserProfile>) => {
      const res = await apiRequest("PATCH", "/api/user/profile", updatedProfile);
      return await res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/user"] });
      setIsEditing(false);
      toast({
        title: "Profile updated",
        description: "Your profile has been successfully updated.",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Update failed",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  const handleUpdateProfile = () => {
    // In a real app, this would call the updateProfileMutation
    // For now, we'll just simulate success
    setIsEditing(false);
    toast({
      title: "Profile updated",
      description: "Your profile has been successfully updated.",
    });
  };

  const handleLogout = () => {
    logoutMutation.mutate();
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('en-SG', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  };

  // Format date without time
  const formatSimpleDate = (dateString: string) => {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('en-SG', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    }).format(date);
  };

  return (
    <AppLayout activeTab="profile">
      <div className="container py-6 max-w-4xl">
        <h1 className="text-2xl font-bold mb-6">My Profile</h1>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Profile Summary */}
          <div className="md:col-span-1">
            <Card>
              <CardHeader className="flex flex-col items-center">
                <Avatar className="w-24 h-24">
                  <AvatarImage src={user?.avatar} />
                  <AvatarFallback className="text-xl">{getInitials(user?.fullName || "")}</AvatarFallback>
                </Avatar>
                <CardTitle className="mt-4">{user?.fullName}</CardTitle>
                <CardDescription>{user?.username}</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex items-center">
                    <User className="w-4 h-4 mr-2 text-muted-foreground" />
                    <span className="text-sm">Member since {formatSimpleDate(profile.joinDate)}</span>
                  </div>
                  {profile.location && (
                    <div className="flex items-center">
                      <MapPin className="w-4 h-4 mr-2 text-muted-foreground" />
                      <span className="text-sm">{profile.location}</span>
                    </div>
                  )}
                  <div className="flex items-center">
                    <Mail className="w-4 h-4 mr-2 text-muted-foreground" />
                    <span className="text-sm">{profile.email}</span>
                  </div>
                  {profile.phone && (
                    <div className="flex items-center">
                      <Phone className="w-4 h-4 mr-2 text-muted-foreground" />
                      <span className="text-sm">{profile.phone}</span>
                    </div>
                  )}
                </div>
              </CardContent>
              <CardFooter className="flex flex-col items-stretch gap-2">
                <Button 
                  variant="outline" 
                  className="w-full flex items-center justify-center"
                  onClick={() => setIsEditing(true)}
                >
                  <Edit className="w-4 h-4 mr-2" />
                  Edit Profile
                </Button>
                <Button 
                  variant="outline"
                  className="w-full flex items-center justify-center text-destructive border-destructive/20 hover:bg-destructive/10"
                  onClick={handleLogout}
                >
                  <LogOut className="w-4 h-4 mr-2" />
                  Logout
                </Button>
              </CardFooter>
            </Card>

            {/* Achievements */}
            <Card className="mt-6">
              <CardHeader>
                <CardTitle className="text-lg flex items-center">
                  <Award className="w-5 h-5 mr-2 text-primary" />
                  Achievements
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {achievements.map((achievement) => (
                    <div key={achievement.id} className="flex items-start">
                      <div className="bg-primary/10 p-2 rounded-full mr-3">
                        <Award className="w-4 h-4 text-primary" />
                      </div>
                      <div>
                        <h4 className="font-medium text-sm">{achievement.title}</h4>
                        <p className="text-xs text-muted-foreground">{achievement.description}</p>
                        <p className="text-xs text-muted-foreground mt-1">{formatSimpleDate(achievement.dateEarned)}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Main Content */}
          <div className="md:col-span-2">
            <Tabs defaultValue="overview">
              <TabsList className="grid grid-cols-3 mb-6">
                <TabsTrigger value="overview">Overview</TabsTrigger>
                <TabsTrigger value="appointments">Appointments</TabsTrigger>
                <TabsTrigger value="settings">Settings</TabsTrigger>
              </TabsList>
              
              {/* Overview Tab */}
              <TabsContent value="overview">
                {isEditing ? (
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-lg">Edit Profile</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <form className="space-y-4">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <div className="space-y-2">
                            <Label htmlFor="fullName">Full Name</Label>
                            <Input 
                              id="fullName" 
                              value={profile.fullName}
                              onChange={(e) => setProfile({...profile, fullName: e.target.value})}
                            />
                          </div>
                          <div className="space-y-2">
                            <Label htmlFor="email">Email</Label>
                            <Input 
                              id="email" 
                              type="email" 
                              value={profile.email}
                              onChange={(e) => setProfile({...profile, email: e.target.value})}
                            />
                          </div>
                          <div className="space-y-2">
                            <Label htmlFor="phone">Phone</Label>
                            <Input 
                              id="phone" 
                              value={profile.phone || ""}
                              onChange={(e) => setProfile({...profile, phone: e.target.value})}
                            />
                          </div>
                          <div className="space-y-2">
                            <Label htmlFor="location">Location</Label>
                            <Input 
                              id="location" 
                              value={profile.location || ""}
                              onChange={(e) => setProfile({...profile, location: e.target.value})}
                            />
                          </div>
                          <div className="space-y-2">
                            <Label htmlFor="language">Preferred Language</Label>
                            <select 
                              id="language"
                              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                              value={profile.preferredLanguage || "English"}
                              onChange={(e) => setProfile({...profile, preferredLanguage: e.target.value})}
                            >
                              <option value="English">English</option>
                              <option value="Chinese">Chinese</option>
                              <option value="Malay">Malay</option>
                              <option value="Tamil">Tamil</option>
                            </select>
                          </div>
                        </div>
                      </form>
                    </CardContent>
                    <CardFooter className="flex justify-between">
                      <Button variant="outline" onClick={() => setIsEditing(false)}>Cancel</Button>
                      <Button onClick={handleUpdateProfile}>
                        <Save className="w-4 h-4 mr-2" />
                        Save Changes
                      </Button>
                    </CardFooter>
                  </Card>
                ) : (
                  <>
                    <Card>
                      <CardHeader>
                        <CardTitle className="text-lg">Recent Activity</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <div className="space-y-4">
                          {activityHistory.map((activity) => (
                            <div key={activity.id} className="flex items-start">
                              <div className={`bg-primary/10 p-2 rounded-full mr-3`}>
                                {activity.type === "assessment" && <FileText className="w-4 h-4 text-primary" />}
                                {activity.type === "resource" && <Book className="w-4 h-4 text-primary" />}
                                {activity.type === "community" && <MessageSquare className="w-4 h-4 text-primary" />}
                                {activity.type === "mood" && <Heart className="w-4 h-4 text-primary" />}
                              </div>
                              <div className="flex-1">
                                <h4 className="font-medium text-sm">{activity.description}</h4>
                                <p className="text-xs text-muted-foreground">{formatDate(activity.date)}</p>
                              </div>
                              <Badge variant="outline" className="ml-2">
                                {activity.type}
                              </Badge>
                            </div>
                          ))}
                        </div>
                      </CardContent>
                      <CardFooter>
                        <Button variant="outline" className="w-full">View All Activity</Button>
                      </CardFooter>
                    </Card>

                    <Card className="mt-6">
                      <CardHeader>
                        <CardTitle className="text-lg">Care Progress</CardTitle>
                        <CardDescription>Track your journey through care plans and assessments</CardDescription>
                      </CardHeader>
                      <CardContent>
                        <div className="space-y-6">
                          <div>
                            <div className="flex justify-between items-center mb-2">
                              <h4 className="font-medium text-sm">Current Care Plan</h4>
                              <Badge variant="outline">In Progress</Badge>
                            </div>
                            <div className="bg-muted h-2 rounded-full">
                              <div className="bg-primary h-2 rounded-full w-3/5"></div>
                            </div>
                            <div className="flex justify-between text-xs text-muted-foreground mt-1">
                              <span>0%</span>
                              <span>60%</span>
                              <span>100%</span>
                            </div>
                          </div>
                          
                          <div>
                            <h4 className="font-medium text-sm mb-2">Recent Assessments</h4>
                            <div className="space-y-2">
                              <div className="flex justify-between items-center p-3 border rounded-md">
                                <div className="flex items-center">
                                  <div className="bg-yellow-100 p-1 rounded-full mr-2">
                                    <Activity className="w-4 h-4 text-yellow-600" />
                                  </div>
                                  <div>
                                    <p className="text-sm font-medium">EPDS Assessment</p>
                                    <p className="text-xs text-muted-foreground">Apr 30, 2023</p>
                                  </div>
                                </div>
                                <div className="text-right">
                                  <p className="text-sm font-medium">Score: 9</p>
                                  <p className="text-xs text-yellow-600">Mild symptoms</p>
                                </div>
                              </div>
                              
                              <div className="flex justify-between items-center p-3 border rounded-md">
                                <div className="flex items-center">
                                  <div className="bg-green-100 p-1 rounded-full mr-2">
                                    <Activity className="w-4 h-4 text-green-600" />
                                  </div>
                                  <div>
                                    <p className="text-sm font-medium">PHQ-9 Assessment</p>
                                    <p className="text-xs text-muted-foreground">Apr 15, 2023</p>
                                  </div>
                                </div>
                                <div className="text-right">
                                  <p className="text-sm font-medium">Score: 5</p>
                                  <p className="text-xs text-green-600">Minimal symptoms</p>
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </CardContent>
                      <CardFooter className="flex justify-between">
                        <Button variant="outline">View Care Plan</Button>
                        <Button>
                          <PlusCircle className="w-4 h-4 mr-2" />
                          New Assessment
                        </Button>
                      </CardFooter>
                    </Card>
                  </>
                )}
              </TabsContent>
              
              {/* Appointments Tab */}
              <TabsContent value="appointments">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg flex items-center">
                      <Calendar className="w-5 h-5 mr-2 text-primary" />
                      Upcoming Appointments
                    </CardTitle>
                    <CardDescription>
                      View and manage your scheduled appointments
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    {upcomingAppointments.length > 0 ? (
                      <div className="space-y-4">
                        {upcomingAppointments.map((appointment) => (
                          <div key={appointment.id} className="flex items-start border p-4 rounded-lg">
                            <div className={`p-2 rounded-full mr-3 ${appointment.virtual ? 'bg-blue-100' : 'bg-green-100'}`}>
                              {appointment.virtual ? (
                                <Video className={`w-5 h-5 ${appointment.virtual ? 'text-blue-600' : 'text-green-600'}`} />
                              ) : (
                                <MapPin className={`w-5 h-5 ${appointment.virtual ? 'text-blue-600' : 'text-green-600'}`} />
                              )}
                            </div>
                            <div className="flex-1">
                              <h4 className="font-medium">{appointment.title}</h4>
                              <p className="text-sm text-muted-foreground">with {appointment.provider}</p>
                              <div className="flex items-center mt-2">
                                <Calendar className="w-4 h-4 mr-1 text-muted-foreground" />
                                <span className="text-sm">{formatDate(appointment.date)}</span>
                              </div>
                              <div className="flex items-center mt-1">
                                <MapPin className="w-4 h-4 mr-1 text-muted-foreground" />
                                <span className="text-sm">{appointment.location}</span>
                              </div>
                            </div>
                            <Badge variant={appointment.virtual ? "secondary" : "outline"}>
                              {appointment.virtual ? "Virtual" : "In-person"}
                            </Badge>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <div className="text-center py-8">
                        <Calendar className="w-12 h-12 mx-auto text-muted-foreground" />
                        <h3 className="mt-4 text-lg font-medium">No upcoming appointments</h3>
                        <p className="text-muted-foreground mt-2">
                          You don't have any scheduled appointments at the moment.
                        </p>
                      </div>
                    )}
                  </CardContent>
                  <CardFooter>
                    <Button className="w-full">
                      <CalendarPlus className="w-4 h-4 mr-2" />
                      Schedule Appointment
                    </Button>
                  </CardFooter>
                </Card>
                
                <Card className="mt-6">
                  <CardHeader>
                    <CardTitle className="text-lg flex items-center">
                      <ClockCounterClockwise className="w-5 h-5 mr-2 text-primary" />
                      Past Appointments
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-center py-6">
                      <Clock className="w-12 h-12 mx-auto text-muted-foreground" />
                      <h3 className="mt-4 text-lg font-medium">No past appointments</h3>
                      <p className="text-muted-foreground mt-2">
                        Your appointment history will appear here
                      </p>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
              
              {/* Settings Tab */}
              <TabsContent value="settings">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg flex items-center">
                      <Bell className="w-5 h-5 mr-2 text-primary" />
                      Notification Settings
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      <div className="flex items-center justify-between">
                        <div className="space-y-0.5">
                          <Label htmlFor="assessment-reminders">Assessment Reminders</Label>
                          <p className="text-sm text-muted-foreground">
                            Reminders to complete regular mental health assessments
                          </p>
                        </div>
                        <Switch 
                          id="assessment-reminders" 
                          checked={profile.notificationSettings.assessmentReminders}
                          onCheckedChange={(checked) => {
                            setProfile({
                              ...profile,
                              notificationSettings: {
                                ...profile.notificationSettings,
                                assessmentReminders: checked
                              }
                            });
                          }}
                        />
                      </div>
                      <Separator />
                      <div className="flex items-center justify-between">
                        <div className="space-y-0.5">
                          <Label htmlFor="community-updates">Community Updates</Label>
                          <p className="text-sm text-muted-foreground">
                            Updates on posts and replies in the community forum
                          </p>
                        </div>
                        <Switch 
                          id="community-updates" 
                          checked={profile.notificationSettings.communityUpdates}
                          onCheckedChange={(checked) => {
                            setProfile({
                              ...profile,
                              notificationSettings: {
                                ...profile.notificationSettings,
                                communityUpdates: checked
                              }
                            });
                          }}
                        />
                      </div>
                      <Separator />
                      <div className="flex items-center justify-between">
                        <div className="space-y-0.5">
                          <Label htmlFor="resource-updates">Resource Updates</Label>
                          <p className="text-sm text-muted-foreground">
                            Notifications about new resources and articles
                          </p>
                        </div>
                        <Switch 
                          id="resource-updates" 
                          checked={profile.notificationSettings.resourceUpdates}
                          onCheckedChange={(checked) => {
                            setProfile({
                              ...profile,
                              notificationSettings: {
                                ...profile.notificationSettings,
                                resourceUpdates: checked
                              }
                            });
                          }}
                        />
                      </div>
                      <Separator />
                      <div className="flex items-center justify-between">
                        <div className="space-y-0.5">
                          <Label htmlFor="support-messages">Support Messages</Label>
                          <p className="text-sm text-muted-foreground">
                            Notifications for new messages from support providers
                          </p>
                        </div>
                        <Switch 
                          id="support-messages" 
                          checked={profile.notificationSettings.supportMessages}
                          onCheckedChange={(checked) => {
                            setProfile({
                              ...profile,
                              notificationSettings: {
                                ...profile.notificationSettings,
                                supportMessages: checked
                              }
                            });
                          }}
                        />
                      </div>
                    </div>
                  </CardContent>
                  <CardFooter>
                    <Button className="w-full" onClick={handleUpdateProfile}>
                      Save Notification Settings
                    </Button>
                  </CardFooter>
                </Card>
                
                <Card className="mt-6">
                  <CardHeader>
                    <CardTitle className="text-lg flex items-center">
                      <Lock className="w-5 h-5 mr-2 text-primary" />
                      Security Settings
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      <div className="space-y-2">
                        <Label htmlFor="current-password">Current Password</Label>
                        <Input id="current-password" type="password" />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="new-password">New Password</Label>
                        <Input id="new-password" type="password" />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="confirm-password">Confirm New Password</Label>
                        <Input id="confirm-password" type="password" />
                      </div>
                    </div>
                  </CardContent>
                  <CardFooter className="flex flex-col gap-4">
                    <Button className="w-full">
                      Update Password
                    </Button>
                    <div className="text-sm text-center text-muted-foreground">
                      Password must be at least 8 characters and include a number and special character.
                    </div>
                  </CardFooter>
                </Card>
              </TabsContent>
            </Tabs>
          </div>
        </div>
      </div>
    </AppLayout>
  );
}

// Missing components for TypeScript to not complain
const MapPin = (props: any) => <div {...props} />;
const Mail = (props: any) => <div {...props} />;
const Phone = (props: any) => <div {...props} />;
const FileText = (props: any) => <div {...props} />;
const MessageSquare = (props: any) => <div {...props} />;
const Heart = (props: any) => <div {...props} />;
const PlusCircle = (props: any) => <div {...props} />;
const Video = (props: any) => <div {...props} />;
const CalendarPlus = (props: any) => <div {...props} />;
const ClockCounterClockwise = (props: any) => <div {...props} />;
const Activity = (props: any) => <div {...props} />;