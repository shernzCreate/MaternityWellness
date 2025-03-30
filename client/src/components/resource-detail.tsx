import { useState, useEffect } from "react";
import { useLocation } from "wouter";
import { ChevronLeft, Clock, Calendar, Bookmark, BookmarkCheck, Share } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/use-auth";
import { useMutation } from "@tanstack/react-query";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { shareContent } from "@/lib/nativeBridge";

interface ResourceDetailProps {
  id: number;
  title: string;
  description: string;
  category: string;
  readTime: number;
  type: "article" | "video";
  content: string;
  publishDate: string;
  author?: string;
  onClose: () => void;
}

export function ResourceDetail({ 
  id, 
  title, 
  description, 
  category, 
  readTime, 
  type, 
  content,
  publishDate,
  author,
  onClose 
}: ResourceDetailProps) {
  const { user } = useAuth();
  const { toast } = useToast();
  const [scrollProgress, setScrollProgress] = useState(0);
  const [isBookmarked, setIsBookmarked] = useState(false);
  const [_, navigate] = useLocation();

  // Format date
  const formattedDate = new Date(publishDate).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });

  // Track reading progress
  useEffect(() => {
    const trackScroll = () => {
      const windowHeight = window.innerHeight;
      const documentHeight = document.documentElement.scrollHeight;
      const scrollTop = window.scrollY;
      
      // Calculate scroll percentage
      if (documentHeight > windowHeight) {
        const scrollPercentage = (scrollTop / (documentHeight - windowHeight)) * 100;
        setScrollProgress(Math.min(Math.round(scrollPercentage), 100));
      }
    };

    window.addEventListener('scroll', trackScroll);
    return () => window.removeEventListener('scroll', trackScroll);
  }, []);
  
  // Record resource viewed mutation
  const recordViewMutation = useMutation({
    mutationFn: async () => {
      if (!user) return;
      const res = await apiRequest('POST', '/api/resources/viewed', { resourceId: id });
      return await res.json();
    },
    onError: (error) => {
      console.error('Error recording resource view:', error);
    }
  });
  
  // Toggle bookmark mutation
  const toggleBookmarkMutation = useMutation({
    mutationFn: async () => {
      if (!user) return;
      const res = await apiRequest('POST', '/api/resources/bookmark', { 
        resourceId: id,
        bookmarked: !isBookmarked 
      });
      return await res.json();
    },
    onSuccess: () => {
      setIsBookmarked(!isBookmarked);
      queryClient.invalidateQueries({ queryKey: ['/api/resources/bookmarks'] });
      toast({
        title: isBookmarked ? 'Bookmark removed' : 'Bookmark added',
        description: isBookmarked ? 'Resource removed from your saved items' : 'Resource saved to your bookmarks',
      });
    },
    onError: (error) => {
      toast({
        title: 'Action failed',
        description: 'Unable to update bookmark status. Please try again.',
        variant: 'destructive',
      });
    }
  });

  // Record resource completed mutation (when progress reaches 90%)
  const recordCompletedMutation = useMutation({
    mutationFn: async () => {
      if (!user) return;
      const res = await apiRequest('POST', '/api/resources/completed', { resourceId: id });
      return await res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/user/progress'] });
    }
  });

  // Handle bookmark toggle
  const handleBookmarkToggle = () => {
    if (!user) {
      toast({
        title: 'Sign in required',
        description: 'Please sign in to bookmark resources.',
        variant: 'destructive',
      });
      return;
    }
    
    toggleBookmarkMutation.mutate();
  };

  // Handle share
  const handleShare = () => {
    shareContent(`${title}\n\n${description}\n\nRead more in the Maternal Wellness app.`);
    
    toast({
      title: 'Content shared',
      description: 'Resource has been shared successfully.',
    });
  };

  // Record view when component mounts
  useEffect(() => {
    recordViewMutation.mutate();
  }, []);
  
  // Mark as completed when progress hits 90%
  useEffect(() => {
    if (scrollProgress >= 90 && user) {
      recordCompletedMutation.mutate();
    }
  }, [scrollProgress, user]);

  // Function to render content with proper formatting
  const renderContent = () => {
    return { __html: content };
  };

  // Extract YouTube video ID from content (if present)
  const getVideoId = () => {
    // Check if content has videoId in an HTML attribute
    const videoIdMatch = content.match(/data-video-id="([^"]+)"/);
    if (videoIdMatch && videoIdMatch[1]) {
      return videoIdMatch[1];
    }
    
    // Default videos for different categories
    if (category === "exercise") {
      // Gentle postpartum exercise video
      return "6SCS-6RtgGg";
    } else if (category === "selfcare") {
      // Mindfulness for new mothers
      return "Hd6fiRvfcAY";
    } else {
      // Default postpartum depression video
      return "O4mHJUqAJ2k";
    }
  };

  // For videos, show video player
  if (type === 'video') {
    const videoId = getVideoId();
    
    return (
      <div className="flex flex-col min-h-screen bg-background pb-20">
        <div className="bg-primary text-white px-4 py-4 sticky top-0 z-10">
          <div className="flex items-center">
            <Button 
              variant="ghost" 
              size="icon" 
              className="mr-2 text-white hover:bg-primary-dark"
              onClick={onClose}
            >
              <ChevronLeft className="h-5 w-5" />
            </Button>
            <h1 className="font-semibold text-lg">{title}</h1>
          </div>
        </div>
        
        <div className="flex-1 px-4 py-4">
          <div className="aspect-video bg-neutral-900 mb-4 rounded-lg overflow-hidden">
            {videoId ? (
              <iframe 
                width="100%" 
                height="100%" 
                src={`https://www.youtube.com/embed/${videoId}`}
                title={title}
                frameBorder="0" 
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                allowFullScreen
              ></iframe>
            ) : (
              <div className="flex items-center justify-center h-full">
                <div className="text-center">
                  <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-white mx-auto mb-2">
                    <polygon points="5 3 19 12 5 21 5 3"></polygon>
                  </svg>
                  <p className="text-white text-sm">Video unavailable</p>
                </div>
              </div>
            )}
          </div>
          
          <h1 className="text-2xl font-bold mb-2">{title}</h1>
          <p className="text-muted-foreground mb-4">{description}</p>
          
          <div className="flex items-center gap-4 mb-6">
            <div className="flex items-center">
              <Clock className="h-4 w-4 mr-1.5 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">{readTime} min</span>
            </div>
            <div className="flex items-center">
              <Calendar className="h-4 w-4 mr-1.5 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">{formattedDate}</span>
            </div>
            <Badge variant="outline" className="ml-auto">
              {category}
            </Badge>
          </div>
          
          <div className="flex justify-between mb-6">
            <Button variant="outline" size="sm" onClick={handleBookmarkToggle}>
              {isBookmarked ? (
                <>
                  <BookmarkCheck className="h-4 w-4 mr-2" />
                  Saved
                </>
              ) : (
                <>
                  <Bookmark className="h-4 w-4 mr-2" />
                  Save
                </>
              )}
            </Button>
            <Button variant="outline" size="sm" onClick={handleShare}>
              <Share className="h-4 w-4 mr-2" />
              Share
            </Button>
          </div>
          
          <div className="prose prose-sm max-w-none">
            <div dangerouslySetInnerHTML={renderContent()} />
          </div>
        </div>
      </div>
    );
  }

  // For articles
  return (
    <div className="flex flex-col min-h-screen bg-background pb-20">
      <div className="bg-primary text-white px-4 py-4 sticky top-0 z-10">
        <div className="flex items-center">
          <Button 
            variant="ghost" 
            size="icon" 
            className="mr-2 text-white hover:bg-primary-dark"
            onClick={onClose}
          >
            <ChevronLeft className="h-5 w-5" />
          </Button>
          <div className="flex-1">
            <h1 className="font-semibold text-lg">{title}</h1>
            <Progress value={scrollProgress} className="h-1 mt-2 bg-white bg-opacity-20" />
          </div>
        </div>
      </div>
      
      <div className="flex-1 px-4 py-4">
        <h1 className="text-2xl font-bold mb-2">{title}</h1>
        <p className="text-muted-foreground mb-4">{description}</p>
        
        <div className="flex items-center gap-4 mb-6">
          <div className="flex items-center">
            <Clock className="h-4 w-4 mr-1.5 text-muted-foreground" />
            <span className="text-sm text-muted-foreground">{readTime} min read</span>
          </div>
          <div className="flex items-center">
            <Calendar className="h-4 w-4 mr-1.5 text-muted-foreground" />
            <span className="text-sm text-muted-foreground">{formattedDate}</span>
          </div>
          <Badge variant="outline" className="ml-auto">
            {category}
          </Badge>
        </div>
        
        <div className="flex justify-between mb-6">
          <Button variant="outline" size="sm" onClick={handleBookmarkToggle}>
            {isBookmarked ? (
              <>
                <BookmarkCheck className="h-4 w-4 mr-2" />
                Saved
              </>
            ) : (
              <>
                <Bookmark className="h-4 w-4 mr-2" />
                Save
              </>
            )}
          </Button>
          <Button variant="outline" size="sm" onClick={handleShare}>
            <Share className="h-4 w-4 mr-2" />
            Share
          </Button>
        </div>
        
        {author && (
          <Card className="mb-6">
            <CardContent className="p-4">
              <div className="flex items-center">
                <div className="w-10 h-10 rounded-full bg-primary text-white flex items-center justify-center font-semibold mr-3">
                  {author.charAt(0)}
                </div>
                <div>
                  <p className="font-medium">{author}</p>
                  <p className="text-sm text-muted-foreground">
                    Maternal Wellness Expert
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        )}
        
        <div className="prose prose-sm max-w-none">
          <div dangerouslySetInnerHTML={renderContent()} />
        </div>
        
        <div className="mt-8 pt-4 border-t">
          <h3 className="font-semibold mb-3">Related Resources</h3>
          <p className="text-muted-foreground text-sm mb-3">Continue learning with these related articles</p>
          <div className="space-y-2">
            <Button variant="outline" className="w-full justify-between py-6 h-auto" onClick={() => navigate('/resources')}>
              <div className="text-left">
                <p className="font-medium">Signs of Postpartum Depression</p>
                <p className="text-sm text-muted-foreground">4 min read</p>
              </div>
              <ChevronLeft className="h-5 w-5 rotate-180" />
            </Button>
            <Button variant="outline" className="w-full justify-between py-6 h-auto" onClick={() => navigate('/resources')}>
              <div className="text-left">
                <p className="font-medium">Self-Care for New Mothers</p>
                <p className="text-sm text-muted-foreground">5 min read</p>
              </div>
              <ChevronLeft className="h-5 w-5 rotate-180" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}