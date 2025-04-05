import { useState, useEffect, useRef } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { useAuth } from "@/hooks/use-auth";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardContent, CardFooter } from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import { getInitials } from "@/lib/utils";
import { MessageCircle, Send, User } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { format, isToday } from "date-fns";

interface Message {
  id: number;
  userId: number;
  userName: string;
  isSupport: boolean;
  content: string;
  timestamp: string;
  read: boolean;
}

interface SupportAgent {
  id: number;
  name: string;
  role: string;
  avatar?: string;
  status: "online" | "offline" | "busy";
  specialization: string;
}

export function ChatSupport() {
  const { user } = useAuth();
  const [message, setMessage] = useState("");
  const { toast } = useToast();
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const [selectedAgent, setSelectedAgent] = useState<SupportAgent | null>(null);
  
  // Fetch support agents
  const { data: supportAgents = [] } = useQuery<SupportAgent[]>({
    queryKey: ["/api/support/agents"],
    queryFn: async () => {
      const res = await fetch("/api/support/agents");
      if (!res.ok) throw new Error("Failed to fetch support agents");
      return res.json();
    }
  });
  
  // Fetch chat messages
  const { data: chatMessages = [] } = useQuery<Message[]>({
    queryKey: ["/api/support/messages", selectedAgent?.id],
    queryFn: async () => {
      if (!selectedAgent) return [];
      const res = await fetch(`/api/support/messages?agentId=${selectedAgent.id}`);
      if (!res.ok) throw new Error("Failed to fetch messages");
      return res.json();
    },
    enabled: !!selectedAgent
  });
  
  // Send message mutation
  const sendMessageMutation = useMutation({
    mutationFn: async (content: string) => {
      if (!selectedAgent) throw new Error("No agent selected");
      const res = await apiRequest("POST", "/api/support/messages", {
        content,
        agentId: selectedAgent.id
      });
      return await res.json();
    },
    onSuccess: (newMessage: Message) => {
      queryClient.setQueryData(
        ["/api/support/messages", selectedAgent?.id],
        (oldMessages: Message[] = []) => [...oldMessages, newMessage]
      );
      
      // Simulate agent response after 1-2 seconds
      setTimeout(() => {
        const responses = [
          "Thank you for sharing. How long have you been feeling this way?",
          "I understand that can be difficult. Have you tried any coping strategies?",
          "It's common to feel that way after childbirth. Would you like me to suggest some resources?",
          "I hear you. Have you discussed these feelings with your family or healthcare provider?",
          "That's important information. Could you tell me more about your sleep patterns?",
          "Self-care is crucial during this time. Are you getting any support at home?"
        ];
        
        const randomResponse = responses[Math.floor(Math.random() * responses.length)];
        
        const agentResponse: Message = {
          id: Date.now(),
          userId: selectedAgent!.id,
          userName: selectedAgent!.name,
          isSupport: true,
          content: randomResponse,
          timestamp: new Date().toISOString(),
          read: false
        };
        
        queryClient.setQueryData(
          ["/api/support/messages", selectedAgent?.id],
          (oldMessages: Message[] = []) => [...oldMessages, agentResponse]
        );
      }, 1000 + Math.random() * 1000);
    },
    onError: (error: Error) => {
      toast({
        title: "Error sending message",
        description: error.message,
        variant: "destructive"
      });
    }
  });
  
  const handleSendMessage = () => {
    if (!message.trim() || !selectedAgent) return;
    
    const tempMessage: Message = {
      id: Date.now(),
      userId: user?.id || 0,
      userName: user?.fullName || "You",
      isSupport: false,
      content: message,
      timestamp: new Date().toISOString(),
      read: true
    };
    
    // Immediately add message to UI
    queryClient.setQueryData(
      ["/api/support/messages", selectedAgent.id],
      (oldMessages: Message[] = []) => [...oldMessages, tempMessage]
    );
    
    sendMessageMutation.mutate(message);
    setMessage("");
  };
  
  // Scroll to bottom when messages change
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [chatMessages]);
  
  const formatMessageTime = (timestamp: string) => {
    const date = new Date(timestamp);
    if (isToday(date)) {
      return format(date, "h:mm a");
    }
    return format(date, "MMM d, h:mm a");
  };
  
  if (!user) {
    return (
      <Card className="min-h-[400px] flex items-center justify-center">
        <CardContent>
          <div className="text-center">
            <MessageCircle className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-medium">Please login to access support chat</h3>
          </div>
        </CardContent>
      </Card>
    );
  }
  
  if (!selectedAgent) {
    return (
      <Card className="min-h-[400px]">
        <CardHeader>
          <h3 className="text-lg font-medium">Select a Support Professional</h3>
          <p className="text-sm text-muted-foreground">
            Choose a professional to start a confidential conversation
          </p>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {supportAgents.map((agent) => (
              <div
                key={agent.id}
                className="flex items-center p-3 rounded-lg border cursor-pointer hover:bg-accent transition-colors"
                onClick={() => setSelectedAgent(agent)}
              >
                <Avatar className="h-10 w-10 mr-3">
                  {agent.avatar ? (
                    <AvatarImage src={agent.avatar} alt={agent.name} />
                  ) : (
                    <AvatarFallback>{getInitials(agent.name)}</AvatarFallback>
                  )}
                </Avatar>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <h4 className="font-medium">{agent.name}</h4>
                    <Badge
                      variant={
                        agent.status === "online"
                          ? "success"
                          : agent.status === "busy"
                          ? "warning"
                          : "secondary"
                      }
                      className="text-xs"
                    >
                      {agent.status}
                    </Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">{agent.role}</p>
                  <p className="text-xs mt-1">{agent.specialization}</p>
                </div>
              </div>
            ))}
            
            {supportAgents.length === 0 && (
              <div className="text-center py-6">
                <User className="mx-auto h-8 w-8 text-muted-foreground mb-2" />
                <p className="text-muted-foreground">No support agents available</p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>
    );
  }
  
  return (
    <Card className="min-h-[500px] flex flex-col">
      <CardHeader className="flex flex-row items-center py-3 px-4 border-b">
        <Avatar className="h-8 w-8 mr-2">
          {selectedAgent.avatar ? (
            <AvatarImage src={selectedAgent.avatar} alt={selectedAgent.name} />
          ) : (
            <AvatarFallback>{getInitials(selectedAgent.name)}</AvatarFallback>
          )}
        </Avatar>
        <div className="flex-1">
          <div className="flex items-center">
            <h3 className="font-medium text-sm">{selectedAgent.name}</h3>
            <Badge
              variant={
                selectedAgent.status === "online"
                  ? "success"
                  : selectedAgent.status === "busy"
                  ? "warning"
                  : "secondary"
              }
              className="ml-2 text-xs py-0 h-5"
            >
              {selectedAgent.status}
            </Badge>
          </div>
          <p className="text-xs text-muted-foreground">{selectedAgent.role}</p>
        </div>
        <Button 
          variant="ghost" 
          size="sm" 
          className="h-8 px-2"
          onClick={() => setSelectedAgent(null)}
        >
          Back
        </Button>
      </CardHeader>
      
      <ScrollArea className="flex-1 p-4">
        <div className="space-y-4">
          {chatMessages.length === 0 ? (
            <div className="text-center py-10">
              <MessageCircle className="mx-auto h-8 w-8 text-muted-foreground mb-2" />
              <p className="text-muted-foreground">Start a conversation with {selectedAgent.name}</p>
              <p className="text-xs text-muted-foreground mt-1">
                All messages are confidential and encrypted
              </p>
            </div>
          ) : (
            chatMessages.map((msg) => (
              <div
                key={msg.id}
                className={`flex ${
                  msg.isSupport ? "justify-start" : "justify-end"
                }`}
              >
                <div
                  className={`max-w-[75%] rounded-lg p-3 ${
                    msg.isSupport
                      ? "bg-accent text-accent-foreground"
                      : "bg-primary text-primary-foreground"
                  }`}
                >
                  <p className="text-sm">{msg.content}</p>
                  <p className="text-xs opacity-70 mt-1 text-right">
                    {formatMessageTime(msg.timestamp)}
                  </p>
                </div>
              </div>
            ))
          )}
          <div ref={messagesEndRef} />
        </div>
      </ScrollArea>
      
      <CardFooter className="p-2 border-t">
        <div className="flex w-full items-center gap-2">
          <Input
            placeholder="Type your message..."
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                handleSendMessage();
              }
            }}
            className="flex-1"
          />
          <Button
            size="icon"
            onClick={handleSendMessage}
            disabled={!message.trim() || sendMessageMutation.isPending}
          >
            <Send className="h-4 w-4" />
          </Button>
        </div>
      </CardFooter>
    </Card>
  );
}