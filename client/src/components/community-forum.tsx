import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { 
  UserPlus, Send, ThumbsUp, MessageSquare, Heart, 
  Clock, Calendar, ArrowRight, Filter, Search,
  Share, Flag, Bookmark, BookmarkCheck, MoreVertical
} from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/use-auth";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { getInitials } from "@/lib/utils";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

interface Post {
  id: number;
  userId: number;
  userName: string;
  userAvatar?: string;
  title: string;
  content: string;
  category: string;
  timestamp: string;
  likes: number;
  comments: number;
  userLiked: boolean;
  userBookmarked: boolean;
  tags: string[];
}

interface Comment {
  id: number;
  postId: number;
  userId: number;
  userName: string;
  userAvatar?: string;
  content: string;
  timestamp: string;
  likes: number;
  userLiked: boolean;
}

export function CommunityForum() {
  const { user } = useAuth();
  const { toast } = useToast();
  const [selectedCategory, setSelectedCategory] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [selectedPost, setSelectedPost] = useState<Post | null>(null);
  const [newComment, setNewComment] = useState<string>("");
  const [newPostDialogOpen, setNewPostDialogOpen] = useState<boolean>(false);
  const [newPostTitle, setNewPostTitle] = useState<string>("");
  const [newPostContent, setNewPostContent] = useState<string>("");
  const [newPostCategory, setNewPostCategory] = useState<string>("general");
  
  // Fetch forum posts
  const { data: posts = [], isLoading: isLoadingPosts } = useQuery<Post[]>({
    queryKey: ["/api/community/posts", selectedCategory, searchQuery],
    queryFn: async () => {
      try {
        const params = new URLSearchParams();
        if (selectedCategory !== "all") {
          params.append("category", selectedCategory);
        }
        if (searchQuery) {
          params.append("search", searchQuery);
        }
        
        const url = `/api/community/posts${params.toString() ? `?${params.toString()}` : ''}`;
        const res = await fetch(url);
        
        if (!res.ok) return mockPosts;
        return await res.json();
      } catch (error) {
        console.error("Error fetching posts:", error);
        return mockPosts;
      }
    }
  });
  
  // Fetch comments for selected post
  const { data: comments = [], isLoading: isLoadingComments } = useQuery<Comment[]>({
    queryKey: ["/api/community/comments", selectedPost?.id],
    queryFn: async () => {
      if (!selectedPost) return [];
      
      try {
        const res = await fetch(`/api/community/comments?postId=${selectedPost.id}`);
        if (!res.ok) return mockComments;
        return await res.json();
      } catch (error) {
        console.error("Error fetching comments:", error);
        return mockComments;
      }
    },
    enabled: !!selectedPost
  });
  
  // Create new post mutation
  const createPostMutation = useMutation({
    mutationFn: async (postData: { title: string; content: string; category: string }) => {
      const res = await apiRequest("POST", "/api/community/posts", postData);
      return await res.json();
    },
    onSuccess: (newPost: Post) => {
      // Close the dialog
      setNewPostDialogOpen(false);
      
      // Clear the form
      setNewPostTitle("");
      setNewPostContent("");
      setNewPostCategory("general");
      
      // Update the posts list
      queryClient.setQueryData(
        ["/api/community/posts", selectedCategory, searchQuery],
        (old: Post[] = []) => [newPost, ...old]
      );
      
      toast({
        title: "Post created",
        description: "Your post has been published to the community",
      });
    },
    onError: (error) => {
      toast({
        title: "Failed to create post",
        description: "Please try again later",
        variant: "destructive",
      });
    },
  });
  
  // Add comment mutation
  const addCommentMutation = useMutation({
    mutationFn: async (commentData: { postId: number; content: string }) => {
      const res = await apiRequest("POST", "/api/community/comments", commentData);
      return await res.json();
    },
    onSuccess: (newComment: Comment) => {
      // Clear the input
      setNewComment("");
      
      // Update the comments list
      queryClient.setQueryData(
        ["/api/community/comments", selectedPost?.id],
        (old: Comment[] = []) => [...old, newComment]
      );
      
      // Update the comment count in the post
      if (selectedPost) {
        const updatedPost = { ...selectedPost, comments: selectedPost.comments + 1 };
        setSelectedPost(updatedPost);
        
        // Update the post in the posts list
        queryClient.setQueryData(
          ["/api/community/posts", selectedCategory, searchQuery],
          (old: Post[] = []) => 
            old.map(post => post.id === updatedPost.id ? updatedPost : post)
        );
      }
    },
    onError: (error) => {
      toast({
        title: "Failed to add comment",
        description: "Please try again later",
        variant: "destructive",
      });
    },
  });
  
  // Toggle like mutation
  const toggleLikeMutation = useMutation({
    mutationFn: async ({ type, id, liked }: { type: 'post' | 'comment', id: number, liked: boolean }) => {
      const res = await apiRequest("POST", `/api/community/${type}s/like`, {
        id,
        liked,
      });
      return await res.json();
    },
    onSuccess: (data, variables) => {
      const { type, id, liked } = variables;
      
      if (type === 'post') {
        // Update the posts list
        queryClient.setQueryData(
          ["/api/community/posts", selectedCategory, searchQuery],
          (old: Post[] = []) => 
            old.map(post => {
              if (post.id !== id) return post;
              
              return {
                ...post,
                likes: liked ? post.likes + 1 : post.likes - 1,
                userLiked: liked,
              };
            })
        );
        
        // Update selected post if needed
        if (selectedPost?.id === id) {
          setSelectedPost({
            ...selectedPost,
            likes: liked ? selectedPost.likes + 1 : selectedPost.likes - 1,
            userLiked: liked,
          });
        }
      } else {
        // Update the comments list
        queryClient.setQueryData(
          ["/api/community/comments", selectedPost?.id],
          (old: Comment[] = []) => 
            old.map(comment => {
              if (comment.id !== id) return comment;
              
              return {
                ...comment,
                likes: liked ? comment.likes + 1 : comment.likes - 1,
                userLiked: liked,
              };
            })
        );
      }
    },
    onError: (error) => {
      toast({
        title: "Action failed",
        description: "Please try again later",
        variant: "destructive",
      });
    },
  });
  
  // Toggle bookmark mutation
  const toggleBookmarkMutation = useMutation({
    mutationFn: async ({ id, bookmarked }: { id: number, bookmarked: boolean }) => {
      const res = await apiRequest("POST", "/api/community/posts/bookmark", {
        id,
        bookmarked,
      });
      return await res.json();
    },
    onSuccess: (data, variables) => {
      const { id, bookmarked } = variables;
      
      // Update the posts list
      queryClient.setQueryData(
        ["/api/community/posts", selectedCategory, searchQuery],
        (old: Post[] = []) => 
          old.map(post => {
            if (post.id !== id) return post;
            
            return {
              ...post,
              userBookmarked: bookmarked,
            };
          })
      );
      
      // Update selected post if needed
      if (selectedPost?.id === id) {
        setSelectedPost({
          ...selectedPost,
          userBookmarked: bookmarked,
        });
      }
      
      toast({
        title: bookmarked ? "Post saved" : "Post unsaved",
        description: bookmarked ? "Added to your bookmarks" : "Removed from your bookmarks",
      });
    },
    onError: (error) => {
      toast({
        title: "Action failed",
        description: "Please try again later",
        variant: "destructive",
      });
    },
  });
  
  // Handle post creation
  const handleCreatePost = () => {
    if (!newPostTitle.trim() || !newPostContent.trim()) {
      toast({
        title: "Missing information",
        description: "Please provide both title and content for your post",
        variant: "destructive",
      });
      return;
    }
    
    createPostMutation.mutate({
      title: newPostTitle,
      content: newPostContent,
      category: newPostCategory,
    });
  };
  
  // Handle comment submission
  const handleSubmitComment = () => {
    if (!newComment.trim() || !selectedPost) return;
    
    addCommentMutation.mutate({
      postId: selectedPost.id,
      content: newComment,
    });
  };
  
  // Handle post like
  const handleLikePost = (post: Post) => {
    toggleLikeMutation.mutate({
      type: 'post',
      id: post.id,
      liked: !post.userLiked,
    });
  };
  
  // Handle comment like
  const handleLikeComment = (comment: Comment) => {
    toggleLikeMutation.mutate({
      type: 'comment',
      id: comment.id,
      liked: !comment.userLiked,
    });
  };
  
  // Handle post bookmark
  const handleBookmarkPost = (post: Post) => {
    toggleBookmarkMutation.mutate({
      id: post.id,
      bookmarked: !post.userBookmarked,
    });
  };
  
  // Handle search submission
  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    // Search is already handled via state and useQuery
  };
  
  // Format date
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (diffInHours < 1) {
      const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60));
      return `${diffInMinutes} min ago`;
    } else if (diffInHours < 24) {
      return `${diffInHours} hour${diffInHours !== 1 ? 's' : ''} ago`;
    } else if (diffInHours < 48) {
      return 'Yesterday';
    } else {
      return date.toLocaleDateString();
    }
  };
  
  // If viewing a single post with comments
  if (selectedPost) {
    return (
      <div>
        <Button 
          variant="ghost" 
          size="sm"
          onClick={() => setSelectedPost(null)}
          className="mb-4"
        >
          Back to All Posts
        </Button>
        
        <Card className="mb-6">
          <CardContent className="pt-6">
            <div className="flex items-center mb-3">
              <Avatar className="h-10 w-10 mr-3">
                <AvatarImage src={selectedPost.userAvatar} alt={selectedPost.userName} />
                <AvatarFallback className="bg-primary text-white">
                  {getInitials(selectedPost.userName)}
                </AvatarFallback>
              </Avatar>
              
              <div className="flex-1">
                <h3 className="font-medium">{selectedPost.userName}</h3>
                <div className="flex items-center text-xs text-muted-foreground">
                  <Calendar className="h-3 w-3 mr-1" />
                  <span>{formatDate(selectedPost.timestamp)}</span>
                  <span className="mx-2">•</span>
                  <Badge variant="outline" className="text-xs">
                    {selectedPost.category}
                  </Badge>
                </div>
              </div>
              
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon">
                    <MoreVertical className="h-5 w-5" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuItem onClick={() => handleBookmarkPost(selectedPost)}>
                    {selectedPost.userBookmarked ? (
                      <>
                        <BookmarkCheck className="mr-2 h-4 w-4" />
                        <span>Saved</span>
                      </>
                    ) : (
                      <>
                        <Bookmark className="mr-2 h-4 w-4" />
                        <span>Save Post</span>
                      </>
                    )}
                  </DropdownMenuItem>
                  <DropdownMenuItem>
                    <Share className="mr-2 h-4 w-4" />
                    <span>Share</span>
                  </DropdownMenuItem>
                  <DropdownMenuItem>
                    <Flag className="mr-2 h-4 w-4" />
                    <span>Report</span>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
            
            <h2 className="text-xl font-semibold mb-3">{selectedPost.title}</h2>
            <p className="mb-4 whitespace-pre-line">{selectedPost.content}</p>
            
            {selectedPost.tags && selectedPost.tags.length > 0 && (
              <div className="flex flex-wrap gap-1 mb-4">
                {selectedPost.tags.map((tag, index) => (
                  <Badge key={index} variant="secondary" className="text-xs">
                    {tag}
                  </Badge>
                ))}
              </div>
            )}
          </CardContent>
          
          <CardFooter className="pt-0 flex items-center justify-between border-t p-4">
            <Button 
              variant={selectedPost.userLiked ? "default" : "outline"} 
              size="sm"
              onClick={() => handleLikePost(selectedPost)}
              className="flex items-center"
            >
              <ThumbsUp className="h-4 w-4 mr-2" />
              {selectedPost.likes > 0 && <span>{selectedPost.likes}</span>}
              <span className="ml-1">Like</span>
            </Button>
            
            <div className="flex items-center text-muted-foreground text-sm">
              <MessageSquare className="h-4 w-4 mr-1" />
              <span>{selectedPost.comments} comments</span>
            </div>
          </CardFooter>
        </Card>
        
        <div className="mb-6">
          <h3 className="font-medium mb-3">Comments ({selectedPost.comments})</h3>
          
          <div className="flex mb-4">
            <Avatar className="h-8 w-8 mr-3">
              <AvatarFallback className="bg-primary text-white">
                {getInitials(user?.fullName || "")}
              </AvatarFallback>
            </Avatar>
            
            <div className="flex-1 flex">
              <Textarea
                placeholder="Write a comment..."
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                className="flex-1 mr-2 min-h-[2.5rem]"
              />
              <Button 
                type="button" 
                onClick={handleSubmitComment}
                disabled={!newComment.trim() || addCommentMutation.isPending}
              >
                <Send className="h-4 w-4" />
                <span className="sr-only">Send</span>
              </Button>
            </div>
          </div>
          
          {isLoadingComments ? (
            <p className="text-center text-muted-foreground py-4">Loading comments...</p>
          ) : comments.length === 0 ? (
            <p className="text-center text-muted-foreground py-4">No comments yet. Be the first to comment!</p>
          ) : (
            <div className="space-y-4">
              {comments.map((comment) => (
                <div key={comment.id} className="flex">
                  <Avatar className="h-8 w-8 mr-3">
                    <AvatarImage src={comment.userAvatar} alt={comment.userName} />
                    <AvatarFallback className="bg-primary text-white">
                      {getInitials(comment.userName)}
                    </AvatarFallback>
                  </Avatar>
                  
                  <div className="flex-1">
                    <div className="bg-muted p-3 rounded-lg">
                      <div className="flex items-center justify-between mb-1">
                        <h4 className="font-medium text-sm">{comment.userName}</h4>
                        <span className="text-xs text-muted-foreground">
                          {formatDate(comment.timestamp)}
                        </span>
                      </div>
                      <p className="text-sm">{comment.content}</p>
                    </div>
                    
                    <div className="flex items-center mt-1 pl-2">
                      <Button 
                        variant="ghost" 
                        size="sm"
                        onClick={() => handleLikeComment(comment)}
                        className={`flex items-center text-xs px-2 h-7 ${comment.userLiked ? 'text-primary' : 'text-muted-foreground'}`}
                      >
                        <ThumbsUp className="h-3 w-3 mr-1" />
                        {comment.likes > 0 && <span>{comment.likes}</span>}
                        <span className="ml-1">Like</span>
                      </Button>
                      <Button 
                        variant="ghost" 
                        size="sm"
                        className="flex items-center text-xs px-2 h-7 text-muted-foreground"
                      >
                        <MessageSquare className="h-3 w-3 mr-1" />
                        <span>Reply</span>
                      </Button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    );
  }
  
  // Forum posts list view
  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-lg font-semibold">Community Forum</h2>
        <Button onClick={() => setNewPostDialogOpen(true)}>
          New Post
        </Button>
      </div>
      
      <div className="mb-6">
        <form onSubmit={handleSearch} className="relative mb-3">
          <Input 
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search discussions..." 
            className="pr-10"
          />
          <Button 
            type="submit"
            variant="ghost" 
            size="icon" 
            className="absolute right-0 top-0 h-full aspect-square"
          >
            <Search className="h-4 w-4" />
          </Button>
        </form>
        
        <div className="flex space-x-2 overflow-x-auto pb-2">
          <Button
            variant={selectedCategory === "all" ? "default" : "outline"}
            size="sm"
            onClick={() => setSelectedCategory("all")}
          >
            All Topics
          </Button>
          <Button
            variant={selectedCategory === "general" ? "default" : "outline"}
            size="sm"
            onClick={() => setSelectedCategory("general")}
          >
            General
          </Button>
          <Button
            variant={selectedCategory === "questions" ? "default" : "outline"}
            size="sm"
            onClick={() => setSelectedCategory("questions")}
          >
            Questions
          </Button>
          <Button
            variant={selectedCategory === "experiences" ? "default" : "outline"}
            size="sm"
            onClick={() => setSelectedCategory("experiences")}
          >
            Experiences
          </Button>
          <Button
            variant={selectedCategory === "advice" ? "default" : "outline"}
            size="sm"
            onClick={() => setSelectedCategory("advice")}
          >
            Advice
          </Button>
          <Button
            variant={selectedCategory === "support" ? "default" : "outline"}
            size="sm"
            onClick={() => setSelectedCategory("support")}
          >
            Support
          </Button>
        </div>
      </div>
      
      {isLoadingPosts ? (
        <p className="text-center text-muted-foreground py-4">Loading posts...</p>
      ) : posts.length === 0 ? (
        <Card>
          <CardContent className="py-8 text-center">
            <p className="text-muted-foreground mb-3">No posts found in this category</p>
            <Button onClick={() => setNewPostDialogOpen(true)}>
              Create the First Post
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {posts.map((post) => (
            <Card key={post.id} className="cursor-pointer" onClick={() => setSelectedPost(post)}>
              <CardContent className="pt-6">
                <div className="flex items-center mb-3">
                  <Avatar className="h-10 w-10 mr-3">
                    <AvatarImage src={post.userAvatar} alt={post.userName} />
                    <AvatarFallback className="bg-primary text-white">
                      {getInitials(post.userName)}
                    </AvatarFallback>
                  </Avatar>
                  
                  <div className="flex-1">
                    <h3 className="font-medium">{post.userName}</h3>
                    <div className="flex items-center text-xs text-muted-foreground">
                      <Calendar className="h-3 w-3 mr-1" />
                      <span>{formatDate(post.timestamp)}</span>
                      <span className="mx-2">•</span>
                      <Badge variant="outline" className="text-xs">
                        {post.category}
                      </Badge>
                    </div>
                  </div>
                  
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button 
                        variant="ghost" 
                        size="icon"
                        onClick={(e) => e.stopPropagation()} // Prevent opening the post
                      >
                        <MoreVertical className="h-5 w-5" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem 
                        onClick={(e) => {
                          e.stopPropagation();
                          handleBookmarkPost(post);
                        }}
                      >
                        {post.userBookmarked ? (
                          <>
                            <BookmarkCheck className="mr-2 h-4 w-4" />
                            <span>Saved</span>
                          </>
                        ) : (
                          <>
                            <Bookmark className="mr-2 h-4 w-4" />
                            <span>Save Post</span>
                          </>
                        )}
                      </DropdownMenuItem>
                      <DropdownMenuItem onClick={(e) => e.stopPropagation()}>
                        <Share className="mr-2 h-4 w-4" />
                        <span>Share</span>
                      </DropdownMenuItem>
                      <DropdownMenuItem onClick={(e) => e.stopPropagation()}>
                        <Flag className="mr-2 h-4 w-4" />
                        <span>Report</span>
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>
                
                <h2 className="text-lg font-semibold mb-3">{post.title}</h2>
                <p className="mb-4 line-clamp-2">{post.content}</p>
                
                {post.tags && post.tags.length > 0 && (
                  <div className="flex flex-wrap gap-1 mb-4">
                    {post.tags.map((tag, index) => (
                      <Badge key={index} variant="secondary" className="text-xs">
                        {tag}
                      </Badge>
                    ))}
                  </div>
                )}
              </CardContent>
              
              <CardFooter className="pt-0 flex items-center justify-between border-t p-4">
                <Button 
                  variant={post.userLiked ? "default" : "outline"} 
                  size="sm"
                  onClick={(e) => {
                    e.stopPropagation();
                    handleLikePost(post);
                  }}
                  className="flex items-center"
                >
                  <ThumbsUp className="h-4 w-4 mr-2" />
                  {post.likes > 0 && <span>{post.likes}</span>}
                  <span className="ml-1">Like</span>
                </Button>
                
                <div className="flex items-center text-muted-foreground text-sm">
                  <MessageSquare className="h-4 w-4 mr-1" />
                  <span>{post.comments} comments</span>
                  <ArrowRight className="h-4 w-4 ml-2" />
                </div>
              </CardFooter>
            </Card>
          ))}
        </div>
      )}
      
      {/* New Post Dialog */}
      <Dialog open={newPostDialogOpen} onOpenChange={setNewPostDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Create a New Post</DialogTitle>
            <DialogDescription>
              Share your thoughts, questions, or experiences with the community.
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <Label htmlFor="title">Title</Label>
              <Input
                id="title"
                placeholder="Give your post a clear title"
                value={newPostTitle}
                onChange={(e) => setNewPostTitle(e.target.value)}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="content">Content</Label>
              <Textarea
                id="content"
                placeholder="Share your thoughts, questions, or experiences..."
                value={newPostContent}
                onChange={(e) => setNewPostContent(e.target.value)}
                rows={5}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="category">Category</Label>
              <Select value={newPostCategory} onValueChange={setNewPostCategory}>
                <SelectTrigger>
                  <SelectValue placeholder="Select a category" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="general">General Discussion</SelectItem>
                  <SelectItem value="questions">Questions</SelectItem>
                  <SelectItem value="experiences">Experiences</SelectItem>
                  <SelectItem value="advice">Advice</SelectItem>
                  <SelectItem value="support">Support</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          
          <DialogFooter>
            <Button variant="outline" onClick={() => setNewPostDialogOpen(false)}>
              Cancel
            </Button>
            <Button 
              onClick={handleCreatePost}
              disabled={createPostMutation.isPending}
            >
              {createPostMutation.isPending ? "Posting..." : "Post"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// Mock data for development
const mockPosts: Post[] = [
  {
    id: 1,
    userId: 2,
    userName: "Jasmine Tan",
    title: "Feeling overwhelmed with a newborn and a toddler",
    content: "I have a 3-week-old baby and a 2-year-old toddler. My husband works long hours, and I'm finding it impossible to manage both kids. My toddler is acting out due to jealousy, and I'm exhausted from lack of sleep. Some days I just break down crying. Has anyone been through this? Any advice would be greatly appreciated.",
    category: "support",
    timestamp: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString(), // 3 hours ago
    likes: 8,
    comments: 5,
    userLiked: false,
    userBookmarked: false,
    tags: ["newborn", "toddler", "exhaustion"]
  },
  {
    id: 2,
    userId: 3,
    userName: "Dr. Mei Ling",
    title: "Understanding Baby Blues vs Postpartum Depression",
    content: "As a maternal mental health specialist, I often see confusion between 'baby blues' and postpartum depression. Baby blues typically last only 2 weeks postpartum and include mood swings and mild sadness. Postpartum depression is more severe, lasting longer and affecting daily functioning. If your symptoms persist beyond two weeks or feel overwhelming, please seek professional help. What questions do you have about the difference?",
    category: "advice",
    timestamp: new Date(Date.now() - 25 * 60 * 60 * 1000).toISOString(), // 25 hours ago
    likes: 42,
    comments: 15,
    userLiked: true,
    userBookmarked: true,
    tags: ["professional", "education", "mental health"]
  },
  {
    id: 3,
    userId: 4,
    userName: "Sarah Wong",
    title: "Successfully weaned off antidepressants - my journey",
    content: "After suffering from PPD for 8 months, I started medication and therapy. The medication helped me stabilize, and the therapy gave me tools to cope. After a year, working closely with my doctor, I successfully weaned off the medication. I wanted to share this to give hope to those who worry they'll be on medication forever. Recovery is possible, though it looks different for everyone. Happy to answer questions about my experience.",
    category: "experiences",
    timestamp: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(), // 5 days ago
    likes: 27,
    comments: 8,
    userLiked: false,
    userBookmarked: false,
    tags: ["recovery", "medication", "hope"]
  },
  {
    id: 4,
    userId: 5,
    userName: "Aisha Binte Mohamed",
    title: "Resources for postnatal depression in Singapore",
    content: "I'm looking for resources for postnatal depression here in Singapore. My sister just had a baby and I'm concerned about her. She's showing signs of depression but is reluctant to seek help. Can anyone recommend culturally sensitive resources or support groups, particularly those that understand our Asian context? Any hotlines or counseling services that have helped you would be appreciated.",
    category: "questions",
    timestamp: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000).toISOString(), // 8 days ago
    likes: 15,
    comments: 12,
    userLiked: false,
    userBookmarked: false,
    tags: ["singapore", "resources", "cultural sensitivity"]
  },
  {
    id: 5,
    userId: 6,
    userName: "Michael Lim",
    title: "Fathers and PPD - supporting your partner while struggling yourself",
    content: "My wife was diagnosed with severe PPD 3 months after our daughter was born. While trying to support her, I realized I was also struggling with depression. It's not often talked about, but fathers can experience postpartum depression too. I found that I needed to take care of my own mental health in order to be there for my wife and baby. Any other dads going through this? What has helped you?",
    category: "experiences",
    timestamp: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000).toISOString(), // 15 days ago
    likes: 34,
    comments: 21,
    userLiked: true,
    userBookmarked: false,
    tags: ["fathers", "partners", "men's mental health"]
  }
];

const mockComments: Comment[] = [
  {
    id: 1,
    postId: 1,
    userId: 3,
    userName: "Dr. Mei Ling",
    content: "What you're experiencing is very common. The transition from one to two children is often more challenging than the first baby. Two specific suggestions: 1) Find small ways for your toddler to 'help' with the baby to address jealousy 2) Consider hiring even occasional help if possible, just to give you a break.",
    timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), // 2 hours ago
    likes: 5,
    userLiked: true
  },
  {
    id: 2,
    postId: 1,
    userId: 7,
    userName: "Priya Singh",
    content: "I went through this exact situation last year. It DOES get better, I promise. One thing that helped was creating special 'mommy and toddler' time during baby's naps. Even 15 minutes of undivided attention made a difference for my toddler's behavior.",
    timestamp: new Date(Date.now() - 2.5 * 60 * 60 * 1000).toISOString(), // 2.5 hours ago
    likes: 3,
    userLiked: false
  },
  {
    id: 3,
    postId: 1,
    userId: 8,
    userName: "Lisa Chen",
    content: "The first few months with two under two was the hardest time of my life. Be gentle with yourself. Lowering standards helped me - paper plates, easy meals, letting the toddler have more screen time than I'd normally allow. Survival mode is ok until things settle.",
    timestamp: new Date(Date.now() - 2.8 * 60 * 60 * 1000).toISOString(), // 2.8 hours ago
    likes: 4,
    userLiked: false
  }
];