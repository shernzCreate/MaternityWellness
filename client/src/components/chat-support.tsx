import { useState, useEffect, useRef } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { 
  UserPlus, Send, Clock, MessageSquare, MessagesSquare,
  BookOpen, User, UserCircle, Shield, Coffee
} from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/use-auth";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { getInitials } from "@/lib/utils";

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
  const { toast } = useToast();
  const [messageText, setMessageText] = useState("");
  const [selectedAgent, setSelectedAgent] = useState<SupportAgent | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  
  // Fetch available support agents
  const { data: supportAgents = [] } = useQuery<SupportAgent[]>({
    queryKey: ["/api/support/agents"],
    queryFn: async () => {
      try {
        const res = await fetch("/api/support/agents");
        if (!res.ok) return mockSupportAgents; // Fallback data
        return await res.json();
      } catch (error) {
        console.error("Error fetching agents:", error);
        return mockSupportAgents; // Fallback data
      }
    }
  });
  
  // Fetch chat history with selected agent
  const { data: messages = [], isLoading: isLoadingMessages } = useQuery<Message[]>({
    queryKey: ["/api/support/messages", selectedAgent?.id],
    queryFn: async () => {
      if (!selectedAgent) return [];
      
      try {
        const res = await fetch(`/api/support/messages?agentId=${selectedAgent.id}`);
        if (!res.ok) return mockMessages; // Fallback data
        return await res.json();
      } catch (error) {
        console.error("Error fetching messages:", error);
        return mockMessages; // Fallback data
      }
    },
    enabled: !!selectedAgent
  });
  
  // Send message mutation
  const sendMessageMutation = useMutation({
    mutationFn: async (content: string) => {
      if (!selectedAgent) throw new Error("No agent selected");
      
      const res = await apiRequest("POST", "/api/support/messages", {
        agentId: selectedAgent.id,
        content,
      });
      return await res.json();
    },
    onSuccess: (newMessage: Message) => {
      // Optimistically update the messages list
      queryClient.setQueryData(
        ["/api/support/messages", selectedAgent?.id],
        (old: Message[] = []) => [...old, newMessage]
      );
      
      // Clear the input
      setMessageText("");
      
      // Scroll to bottom
      scrollToBottom();
      
      // Simulate agent response after a delay
      setTimeout(() => {
        const responseText = getAutomaticResponse(messageText);
        const agentResponse: Message = {
          id: Date.now(),
          userId: selectedAgent?.id || 0,
          userName: selectedAgent?.name || "Support Agent",
          isSupport: true,
          content: responseText,
          timestamp: new Date().toISOString(),
          read: false,
        };
        
        // Add the agent response to the messages
        queryClient.setQueryData(
          ["/api/support/messages", selectedAgent?.id],
          (old: Message[] = []) => [...old, agentResponse]
        );
        
        // Scroll to bottom again
        scrollToBottom();
      }, 1500);
    },
    onError: (error) => {
      toast({
        title: "Failed to send message",
        description: "Please try again later",
        variant: "destructive",
      });
    },
  });
  
  // Handle sending a message
  const handleSendMessage = () => {
    if (!messageText.trim()) return;
    if (!selectedAgent) {
      toast({
        title: "Please select a support agent",
        description: "Choose an agent to start a conversation",
        variant: "destructive",
      });
      return;
    }
    
    const tempMessage: Message = {
      id: Date.now(),
      userId: user?.id || 0,
      userName: user?.fullName || "You",
      isSupport: false,
      content: messageText,
      timestamp: new Date().toISOString(),
      read: true,
    };
    
    // Optimistically add the message
    queryClient.setQueryData(
      ["/api/support/messages", selectedAgent?.id],
      (old: Message[] = []) => [...old, tempMessage]
    );
    
    // Send the message to the server
    sendMessageMutation.mutate(messageText);
  };
  
  // Scroll to bottom of message list when messages change
  useEffect(() => {
    scrollToBottom();
  }, [messages]);
  
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };
  
  // Automatic response based on message content
  const getAutomaticResponse = (message: string) => {
    const lowerMessage = message.toLowerCase();
    
    if (lowerMessage.includes("help") || lowerMessage.includes("support")) {
      return "I'm here to help! What specific challenges are you facing with postpartum depression?";
    } else if (lowerMessage.includes("sad") || lowerMessage.includes("depress") || lowerMessage.includes("anxious")) {
      return "I'm sorry to hear you're feeling this way. Many new mothers experience similar emotions. Have you spoken with your healthcare provider about these feelings?";
    } else if (lowerMessage.includes("sleep") || lowerMessage.includes("tired") || lowerMessage.includes("exhausted")) {
      return "Sleep deprivation can greatly impact your mental health. Try to sleep when your baby sleeps, and don't hesitate to ask for help from friends or family so you can get more rest.";
    } else if (lowerMessage.includes("baby") || lowerMessage.includes("infant") || lowerMessage.includes("child")) {
      return "Your baby's wellbeing is closely connected to yours. Taking care of yourself is an important part of caring for your baby. Is there a specific concern about your baby you'd like to discuss?";
    } else if (lowerMessage.includes("medication") || lowerMessage.includes("medicine") || lowerMessage.includes("drug")) {
      return "Medication can be an effective treatment for PPD. It's important to discuss any questions or concerns about medication with your doctor, as they can provide personalized advice.";
    } else if (lowerMessage.includes("partner") || lowerMessage.includes("husband") || lowerMessage.includes("wife") || lowerMessage.includes("spouse")) {
      return "Partners can provide crucial support during this time. Open communication about your needs and feelings is important. Would you like some strategies for improving communication with your partner?";
    } else if (lowerMessage.includes("thank")) {
      return "You're very welcome! I'm here to support you through this journey. Is there anything else I can help with?";
    } else {
      return "Thank you for sharing. It's important to express your feelings during this time. Would you like to tell me more about what you're experiencing?";
    }
  };
  
  // Render agent selection view if no agent is selected
  if (!selectedAgent) {
    return (
      <div>
        <h2 className="text-lg font-semibold mb-4">Select a Support Professional</h2>
        <p className="text-muted-foreground mb-6">
          Our mental health professionals are here to provide support and guidance. 
          Select a professional to start a confidential conversation.
        </p>
        
        <div className="space-y-3">
          {supportAgents.map((agent) => (
            <Card 
              key={agent.id}
              className="cursor-pointer hover:border-primary transition-colors"
              onClick={() => setSelectedAgent(agent)}
            >
              <CardContent className="p-4 flex items-center">
                <Avatar className="h-12 w-12 mr-4">
                  <AvatarImage src={agent.avatar} alt={agent.name} />
                  <AvatarFallback className="bg-primary text-white">
                    {getInitials(agent.name)}
                  </AvatarFallback>
                </Avatar>
                
                <div className="flex-1">
                  <div className="flex items-center">
                    <h3 className="font-medium">{agent.name}</h3>
                    <Badge 
                      variant={agent.status === "online" ? "default" : "secondary"}
                      className={`ml-2 px-2 py-0 text-xs ${agent.status === "online" ? "bg-green-500" : ""}`}
                    >
                      {agent.status === "online" ? "Available" : agent.status}
                    </Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">{agent.role}</p>
                  <p className="text-xs text-muted-foreground mt-1">
                    Specializes in: {agent.specialization}
                  </p>
                </div>
                
                <Button size="sm" variant="ghost" className="ml-2">
                  <MessageSquare className="h-4 w-4 mr-2" />
                  Chat
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
        
        <div className="mt-6 pt-6 border-t">
          <h3 className="text-sm font-medium mb-3">Other Support Options</h3>
          <div className="space-y-2">
            <Card>
              <CardContent className="p-3 flex items-center">
                <MessagesSquare className="h-5 w-5 mr-3 text-primary" />
                <div>
                  <h4 className="font-medium text-sm">Community Group Chat</h4>
                  <p className="text-xs text-muted-foreground">Connect with other mothers</p>
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardContent className="p-3 flex items-center">
                <BookOpen className="h-5 w-5 mr-3 text-primary" />
                <div>
                  <h4 className="font-medium text-sm">Self-Help Resources</h4>
                  <p className="text-xs text-muted-foreground">Access our library of articles</p>
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardContent className="p-3 flex items-center">
                <UserCircle className="h-5 w-5 mr-3 text-primary" />
                <div>
                  <h4 className="font-medium text-sm">Find Local Support</h4>
                  <p className="text-xs text-muted-foreground">Locate services in your area</p>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    );
  }
  
  // Render chat view if agent is selected
  return (
    <div className="flex flex-col h-[calc(100vh-13rem)]">
      {/* Agent header */}
      <div className="flex items-center p-3 border-b mb-3">
        <Button 
          variant="ghost" 
          size="sm"
          onClick={() => setSelectedAgent(null)}
          className="mr-2"
        >
          Back
        </Button>
        
        <Avatar className="h-10 w-10 mr-3">
          <AvatarImage src={selectedAgent.avatar} alt={selectedAgent.name} />
          <AvatarFallback className="bg-primary text-white">
            {getInitials(selectedAgent.name)}
          </AvatarFallback>
        </Avatar>
        
        <div className="flex-1">
          <div className="flex items-center">
            <h3 className="font-medium">{selectedAgent.name}</h3>
            <Badge 
              variant={selectedAgent.status === "online" ? "default" : "secondary"}
              className={`ml-2 px-2 py-0 text-xs ${selectedAgent.status === "online" ? "bg-green-500" : ""}`}
            >
              {selectedAgent.status === "online" ? "Available" : selectedAgent.status}
            </Badge>
          </div>
          <p className="text-xs text-muted-foreground">{selectedAgent.role}</p>
        </div>
      </div>
      
      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-4">
        {/* Welcome message */}
        <div className="bg-muted p-3 rounded-lg">
          <div className="flex items-center mb-2">
            <Shield className="h-4 w-4 mr-2 text-primary" />
            <p className="text-xs font-medium">Private & Confidential</p>
          </div>
          <p className="text-sm">
            Your conversation is private and protected. Please remember this is not emergency support. 
            If you're in crisis, call 995 or visit your nearest emergency room.
          </p>
        </div>
        
        {/* Agent welcome message */}
        <div className="flex items-start">
          <Avatar className="h-8 w-8 mr-2 mt-1">
            <AvatarImage src={selectedAgent.avatar} alt={selectedAgent.name} />
            <AvatarFallback className="bg-primary text-white text-xs">
              {getInitials(selectedAgent.name)}
            </AvatarFallback>
          </Avatar>
          <div className="bg-primary bg-opacity-10 text-foreground rounded-lg p-3 max-w-[80%]">
            <p className="text-sm">
              Hello! I'm {selectedAgent.name}, a {selectedAgent.role.toLowerCase()} specializing in {selectedAgent.specialization.toLowerCase()}. 
              How can I support you today?
            </p>
            <div className="text-xs text-muted-foreground mt-1 flex items-center">
              <Clock className="h-3 w-3 mr-1" />
              Just now
            </div>
          </div>
        </div>
        
        {/* Message list */}
        {messages.map((message, index) => (
          <div 
            key={message.id || index}
            className={`flex ${!message.isSupport ? 'justify-end' : 'items-start'}`}
          >
            {message.isSupport && (
              <Avatar className="h-8 w-8 mr-2 mt-1">
                <AvatarImage src={selectedAgent.avatar} alt={selectedAgent.name} />
                <AvatarFallback className="bg-primary text-white text-xs">
                  {getInitials(selectedAgent.name)}
                </AvatarFallback>
              </Avatar>
            )}
            
            <div 
              className={`rounded-lg p-3 max-w-[80%] ${
                message.isSupport 
                  ? 'bg-primary bg-opacity-10 text-foreground'
                  : 'bg-primary text-primary-foreground ml-auto'
              }`}
            >
              <p className="text-sm">{message.content}</p>
              <div className="text-xs mt-1 flex items-center">
                <Clock className="h-3 w-3 mr-1" />
                <span className={message.isSupport ? 'text-muted-foreground' : 'text-primary-foreground opacity-80'}>
                  {new Date(message.timestamp).toLocaleTimeString([], {
                    hour: '2-digit',
                    minute: '2-digit'
                  })}
                </span>
              </div>
            </div>
          </div>
        ))}
        
        {/* Typing indicator when sending */}
        {sendMessageMutation.isPending && (
          <div className="flex items-start">
            <Avatar className="h-8 w-8 mr-2 mt-1">
              <AvatarImage src={selectedAgent.avatar} alt={selectedAgent.name} />
              <AvatarFallback className="bg-primary text-white text-xs">
                {getInitials(selectedAgent.name)}
              </AvatarFallback>
            </Avatar>
            <div className="bg-primary bg-opacity-10 rounded-lg p-3">
              <div className="flex space-x-1">
                <div className="bg-primary h-2 w-2 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
                <div className="bg-primary h-2 w-2 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
                <div className="bg-primary h-2 w-2 rounded-full animate-bounce" style={{ animationDelay: '600ms' }}></div>
              </div>
            </div>
          </div>
        )}
        
        {/* Empty div for scrolling to bottom */}
        <div ref={messagesEndRef} />
      </div>
      
      {/* Message input */}
      <div className="bg-background bottom-0 w-full p-3 border-t">
        <div className="flex">
          <Input
            placeholder="Type your message..."
            value={messageText}
            onChange={(e) => setMessageText(e.target.value)}
            className="flex-1 mr-2"
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                handleSendMessage();
              }
            }}
          />
          <Button 
            type="button" 
            onClick={handleSendMessage}
            disabled={!messageText.trim() || sendMessageMutation.isPending}
          >
            <Send className="h-4 w-4" />
            <span className="sr-only">Send</span>
          </Button>
        </div>
        <p className="text-xs text-muted-foreground mt-2">
          <Coffee className="h-3 w-3 inline mr-1" />
          Response times may vary. Thank you for your patience.
        </p>
      </div>
    </div>
  );
}

// Mock data for development
const mockSupportAgents: SupportAgent[] = [
  {
    id: 1,
    name: "Dr. Sarah Tan",
    role: "Clinical Psychologist",
    status: "online",
    specialization: "Postpartum Depression & Anxiety",
  },
  {
    id: 2,
    name: "Mei Lin Wong",
    role: "Counselor",
    status: "online",
    specialization: "Family Therapy & Relationship Issues",
  },
  {
    id: 3,
    name: "Dr. Ahmad Khan",
    role: "Psychiatrist",
    status: "offline",
    specialization: "Mood Disorders & Medication Management",
  },
  {
    id: 4,
    name: "Priya Sharma",
    role: "Social Worker",
    status: "online",
    specialization: "Support Resources & Community Services",
  },
];

const mockMessages: Message[] = [
  // Empty by default to simulate a new conversation
];