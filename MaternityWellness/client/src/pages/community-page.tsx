import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { useLocation } from "wouter";
import { AppLayout } from "@/components/app-layout";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { 
  MessageCircle, Users, UserPlus, Send, ThumbsUp, 
  Heart, Clock, Calendar, ArrowRight, MessageSquare 
} from "lucide-react";
import { useAuth } from "@/hooks/use-auth";
import { getInitials } from "@/lib/utils";
import { ChatSupport } from "@/components/chat-support";
import { CommunityForum } from "@/components/community-forum";

export default function CommunityPage() {
  const [activeTab, setActiveTab] = useState<"forum" | "chat">("forum");
  const { user } = useAuth();
  const [location] = useLocation();
  
  // Check URL for tab parameter
  useEffect(() => {
    const searchParams = window.location.search;
    const params = new URLSearchParams(searchParams);
    const tabParam = params.get('tab');
    if (tabParam === 'chat' || tabParam === 'forum') {
      setActiveTab(tabParam);
    }
  }, []);
  
  return (
    <AppLayout activeTab="community">
      <div className="bg-primary text-white px-4 py-6">
        <h1 className="font-bold text-xl mb-1">Community & Support</h1>
        <p className="text-sm text-white text-opacity-90">
          Connect with others and get professional support
        </p>
      </div>
      
      <div className="p-4">
        <Tabs defaultValue="forum" value={activeTab} onValueChange={(value) => setActiveTab(value as "forum" | "chat")}>
          <TabsList className="grid w-full grid-cols-2 mb-6">
            <TabsTrigger value="forum" className="flex items-center">
              <Users className="w-4 h-4 mr-2" />
              Community Forum
            </TabsTrigger>
            <TabsTrigger value="chat" className="flex items-center">
              <MessageCircle className="w-4 h-4 mr-2" />
              Support Chat
            </TabsTrigger>
          </TabsList>
          
          <TabsContent value="forum" className="mt-0">
            <CommunityForum />
          </TabsContent>
          
          <TabsContent value="chat" className="mt-0">
            <ChatSupport />
          </TabsContent>
        </Tabs>
        
        {/* Coming Soon / In Progress Features */}
        <Card className="mt-8 bg-accent/10 border-accent">
          <CardContent className="p-6">
            <h3 className="font-bold text-lg mb-4 flex items-center">
              <Clock className="w-5 h-5 mr-2 text-accent" />
              Features In Progress
            </h3>
            <div className="space-y-3">
              <div className="flex items-start gap-3">
                <div className="bg-accent/20 p-1 rounded-full">
                  <Users className="w-4 h-4 text-accent" />
                </div>
                <div>
                  <h4 className="font-medium text-sm">Support Groups</h4>
                  <p className="text-sm text-muted-foreground">Weekly virtual support groups led by experienced facilitators</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="bg-accent/20 p-1 rounded-full">
                  <Calendar className="w-4 h-4 text-accent" />
                </div>
                <div>
                  <h4 className="font-medium text-sm">Events Calendar</h4>
                  <p className="text-sm text-muted-foreground">Local and online events related to maternal mental health</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="bg-accent/20 p-1 rounded-full">
                  <MessageSquare className="w-4 h-4 text-accent" />
                </div>
                <div>
                  <h4 className="font-medium text-sm">Private Messaging</h4>
                  <p className="text-sm text-muted-foreground">Direct messaging between community members</p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}