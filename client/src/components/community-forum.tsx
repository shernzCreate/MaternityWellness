import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { useAuth } from "@/hooks/use-auth";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardFooter, CardHeader } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { ScrollArea } from "@/components/ui/scroll-area";
import { ThumbsUp, MessageSquare, BookmarkPlus, BookmarkCheck, Send, Clock, User } from "lucide-react";
import { getInitials } from "@/lib/utils";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { format, formatDistanceToNow } from "date-fns";

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
  const [category, setCategory] = useState<string>("all");
  const [selectedPost, setSelectedPost] = useState<Post | null>(null);
  const [newPostTitle, setNewPostTitle] = useState("");
  const [newPostContent, setNewPostContent] = useState("");
  const [newPostCategory, setNewPostCategory] = useState("General");
  const [newComment, setNewComment] = useState("");
  const [showNewPostForm, setShowNewPostForm] = useState(false);
  
  // Fetch posts based on category
  const { data: posts = [] } = useQuery<Post[]>({
    queryKey: ["/api/community/posts", category],
    queryFn: async () => {
      const url = category === "all" 
        ? "/api/community/posts" 
        : `/api/community/posts?category=${category}`;
      const res = await fetch(url);
      if (!res.ok) throw new Error("Failed to fetch posts");
      return res.json();
    }
  });
  
  // Fetch comments for a selected post
  const { data: comments = [] } = useQuery<Comment[]>({
    queryKey: ["/api/community/comments", selectedPost?.id],
    queryFn: async () => {
      if (!selectedPost) return [];
      const res = await fetch(`/api/community/comments?postId=${selectedPost.id}`);
      if (!res.ok) throw new Error("Failed to fetch comments");
      return res.json();
    },
    enabled: !!selectedPost
  });
  
  // Create post mutation
  const createPostMutation = useMutation({
    mutationFn: async (postData: { title: string; content: string; category: string }) => {
      const res = await apiRequest("POST", "/api/community/posts", postData);
      return await res.json();
    },
    onSuccess: (newPost: Post) => {
      queryClient.setQueryData(
        ["/api/community/posts", category],
        (oldPosts: Post[] = []) => [newPost, ...oldPosts]
      );
      setNewPostTitle("");
      setNewPostContent("");
      setShowNewPostForm(false);
      toast({
        title: "Post created",
        description: "Your post has been published to the community",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error creating post",
        description: error.message,
        variant: "destructive"
      });
    }
  });
  
  // Create comment mutation
  const createCommentMutation = useMutation({
    mutationFn: async (commentData: { content: string; postId: number }) => {
      const res = await apiRequest("POST", "/api/community/comments", commentData);
      return await res.json();
    },
    onSuccess: (newComment: Comment) => {
      queryClient.setQueryData(
        ["/api/community/comments", selectedPost?.id],
        (oldComments: Comment[] = []) => [...oldComments, newComment]
      );
      
      // Update comment count in the post
      if (selectedPost) {
        queryClient.setQueryData(
          ["/api/community/posts", category],
          (oldPosts: Post[] = []) =>
            oldPosts.map((post) =>
              post.id === selectedPost.id
                ? { ...post, comments: post.comments + 1 }
                : post
            )
        );
        
        // Also update the selected post
        setSelectedPost({
          ...selectedPost,
          comments: selectedPost.comments + 1
        });
      }
      
      setNewComment("");
    },
    onError: (error: Error) => {
      toast({
        title: "Error adding comment",
        description: error.message,
        variant: "destructive"
      });
    }
  });
  
  // Like post mutation
  const likePostMutation = useMutation({
    mutationFn: async (postId: number) => {
      const res = await apiRequest("POST", `/api/community/posts/${postId}/like`, {});
      return await res.json();
    },
    onSuccess: (updatedPost: Post) => {
      // Update in posts list
      queryClient.setQueryData(
        ["/api/community/posts", category],
        (oldPosts: Post[] = []) =>
          oldPosts.map((post) =>
            post.id === updatedPost.id ? updatedPost : post
          )
      );
      
      // Update selected post if it's the one that was liked
      if (selectedPost && selectedPost.id === updatedPost.id) {
        setSelectedPost(updatedPost);
      }
    }
  });
  
  // Like comment mutation
  const likeCommentMutation = useMutation({
    mutationFn: async ({ postId, commentId }: { postId: number; commentId: number }) => {
      const res = await apiRequest("POST", `/api/community/comments/${commentId}/like`, {
        postId
      });
      return await res.json();
    },
    onSuccess: (updatedComment: Comment) => {
      queryClient.setQueryData(
        ["/api/community/comments", selectedPost?.id],
        (oldComments: Comment[] = []) =>
          oldComments.map((comment) =>
            comment.id === updatedComment.id ? updatedComment : comment
          )
      );
    }
  });
  
  // Bookmark post mutation
  const bookmarkPostMutation = useMutation({
    mutationFn: async (postId: number) => {
      const res = await apiRequest("POST", `/api/community/posts/${postId}/bookmark`, {});
      return await res.json();
    },
    onSuccess: (updatedPost: Post) => {
      // Update in posts list
      queryClient.setQueryData(
        ["/api/community/posts", category],
        (oldPosts: Post[] = []) =>
          oldPosts.map((post) =>
            post.id === updatedPost.id ? updatedPost : post
          )
      );
      
      // Update selected post if it's the one that was bookmarked
      if (selectedPost && selectedPost.id === updatedPost.id) {
        setSelectedPost(updatedPost);
      }
    }
  });
  
  const handleCreatePost = () => {
    if (!newPostTitle.trim() || !newPostContent.trim()) {
      toast({
        title: "Missing information",
        description: "Please provide both a title and content for your post",
        variant: "destructive"
      });
      return;
    }
    
    createPostMutation.mutate({
      title: newPostTitle,
      content: newPostContent,
      category: newPostCategory
    });
  };
  
  const handleCreateComment = () => {
    if (!newComment.trim() || !selectedPost) return;
    
    createCommentMutation.mutate({
      content: newComment,
      postId: selectedPost.id
    });
  };
  
  const handleLikePost = (post: Post) => {
    if (!user) {
      toast({
        title: "Please login",
        description: "You need to be logged in to like posts",
        variant: "destructive"
      });
      return;
    }
    
    likePostMutation.mutate(post.id);
  };
  
  const handleLikeComment = (comment: Comment) => {
    if (!user || !selectedPost) {
      toast({
        title: "Please login",
        description: "You need to be logged in to like comments",
        variant: "destructive"
      });
      return;
    }
    
    likeCommentMutation.mutate({
      postId: selectedPost.id,
      commentId: comment.id
    });
  };
  
  const handleBookmarkPost = (post: Post) => {
    if (!user) {
      toast({
        title: "Please login",
        description: "You need to be logged in to bookmark posts",
        variant: "destructive"
      });
      return;
    }
    
    bookmarkPostMutation.mutate(post.id);
  };
  
  const formatTimestamp = (timestamp: string) => {
    const date = new Date(timestamp);
    return formatDistanceToNow(date, { addSuffix: true });
  };
  
  const categoryOptions = [
    { value: "all", label: "All Posts" },
    { value: "General", label: "General" },
    { value: "Questions", label: "Questions" },
    { value: "Experiences", label: "Experiences" },
    { value: "Advice", label: "Advice" },
    { value: "Support", label: "Support" },
  ];
  
  if (!user) {
    return (
      <Card className="min-h-[400px] flex items-center justify-center">
        <CardContent>
          <div className="text-center">
            <User className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-medium">Please login to access the community forum</h3>
            <p className="text-sm text-muted-foreground mt-2">
              Join our supportive community of parents sharing experiences
            </p>
          </div>
        </CardContent>
      </Card>
    );
  }
  
  if (selectedPost) {
    return (
      <Card className="min-h-[600px] flex flex-col">
        <CardHeader className="pb-3 border-b">
          <div className="flex justify-between items-start mb-2">
            <Button 
              variant="ghost" 
              size="sm" 
              className="p-0 h-8"
              onClick={() => setSelectedPost(null)}
            >
              &larr; Back to posts
            </Button>
            
            <div className="flex items-center gap-2">
              <Button
                variant="ghost"
                size="sm"
                className="flex items-center gap-1"
                onClick={() => handleLikePost(selectedPost)}
              >
                <ThumbsUp className={`h-4 w-4 ${selectedPost.userLiked ? "fill-current text-primary" : ""}`} />
                <span>{selectedPost.likes}</span>
              </Button>
              
              <Button
                variant="ghost"
                size="sm"
                className="flex items-center gap-1"
                onClick={() => handleBookmarkPost(selectedPost)}
              >
                {selectedPost.userBookmarked ? (
                  <BookmarkCheck className="h-4 w-4 fill-current text-primary" />
                ) : (
                  <BookmarkPlus className="h-4 w-4" />
                )}
              </Button>
            </div>
          </div>
          
          <div className="flex items-start gap-3">
            <Avatar className="h-10 w-10">
              {selectedPost.userAvatar ? (
                <AvatarImage src={selectedPost.userAvatar} alt={selectedPost.userName} />
              ) : (
                <AvatarFallback>{getInitials(selectedPost.userName)}</AvatarFallback>
              )}
            </Avatar>
            
            <div className="flex-1">
              <h3 className="text-lg font-semibold">{selectedPost.title}</h3>
              <div className="flex items-center gap-2 text-xs text-muted-foreground mt-1">
                <span className="font-medium">{selectedPost.userName}</span>
                <span>•</span>
                <span>{formatTimestamp(selectedPost.timestamp)}</span>
                <span>•</span>
                <Badge variant="outline" className="text-xs">
                  {selectedPost.category}
                </Badge>
              </div>
            </div>
          </div>
        </CardHeader>
        
        <ScrollArea className="flex-1 p-4">
          <div className="space-y-6">
            <div className="whitespace-pre-wrap">{selectedPost.content}</div>
            
            {selectedPost.tags && selectedPost.tags.length > 0 && (
              <div className="flex flex-wrap gap-2 mt-4">
                {selectedPost.tags.map((tag) => (
                  <Badge key={tag} variant="secondary" className="text-xs">
                    {tag}
                  </Badge>
                ))}
              </div>
            )}
            
            <div className="pt-4 border-t">
              <h4 className="font-medium mb-4">
                Comments ({selectedPost.comments})
              </h4>
              
              <div className="space-y-4">
                {comments.map((comment) => (
                  <div key={comment.id} className="py-3">
                    <div className="flex items-start gap-3">
                      <Avatar className="h-7 w-7">
                        {comment.userAvatar ? (
                          <AvatarImage src={comment.userAvatar} alt={comment.userName} />
                        ) : (
                          <AvatarFallback>{getInitials(comment.userName)}</AvatarFallback>
                        )}
                      </Avatar>
                      
                      <div className="flex-1">
                        <div className="bg-accent rounded-lg p-3">
                          <div className="flex justify-between items-start">
                            <span className="font-medium text-sm">{comment.userName}</span>
                            <span className="text-xs text-muted-foreground">
                              {formatTimestamp(comment.timestamp)}
                            </span>
                          </div>
                          <p className="mt-1 text-sm">{comment.content}</p>
                        </div>
                        
                        <Button
                          variant="ghost"
                          size="sm"
                          className="flex items-center gap-1 mt-1 h-7 p-1 text-xs"
                          onClick={() => handleLikeComment(comment)}
                        >
                          <ThumbsUp className={`h-3 w-3 ${comment.userLiked ? "fill-current text-primary" : ""}`} />
                          <span>{comment.likes}</span>
                        </Button>
                      </div>
                    </div>
                  </div>
                ))}
                
                {comments.length === 0 && (
                  <div className="text-center py-6 text-muted-foreground">
                    <MessageSquare className="mx-auto h-6 w-6 mb-2 opacity-50" />
                    <p>No comments yet. Be the first to comment!</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </ScrollArea>
        
        <CardFooter className="p-3 border-t gap-3">
          <Avatar className="h-8 w-8 flex-shrink-0">
            <AvatarFallback>{getInitials(user.fullName || 'You')}</AvatarFallback>
          </Avatar>
          <div className="flex flex-1 items-center gap-2">
            <Input
              placeholder="Add a comment..."
              value={newComment}
              onChange={(e) => setNewComment(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter" && !e.shiftKey) {
                  e.preventDefault();
                  handleCreateComment();
                }
              }}
              className="flex-1"
            />
            <Button
              size="sm"
              className="flex-shrink-0"
              onClick={handleCreateComment}
              disabled={!newComment.trim() || createCommentMutation.isPending}
            >
              <Send className="h-4 w-4 mr-1" />
              Post
            </Button>
          </div>
        </CardFooter>
      </Card>
    );
  }
  
  return (
    <div className="space-y-4">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
        <Tabs 
          value={category} 
          onValueChange={setCategory}
          className="w-full sm:w-auto"
        >
          <TabsList className="w-full sm:w-auto">
            {categoryOptions.slice(0, 3).map((option) => (
              <TabsTrigger key={option.value} value={option.value}>
                {option.label}
              </TabsTrigger>
            ))}
          </TabsList>
        </Tabs>
        
        <Button
          onClick={() => setShowNewPostForm(!showNewPostForm)}
          variant={showNewPostForm ? "secondary" : "default"}
          className="sm:ml-auto"
        >
          {showNewPostForm ? "Cancel" : "Create Post"}
        </Button>
      </div>
      
      {showNewPostForm && (
        <Card className="mb-6">
          <CardHeader className="pb-3">
            <h3 className="font-medium">Create a New Post</h3>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid gap-3">
              <Input
                placeholder="Post title"
                value={newPostTitle}
                onChange={(e) => setNewPostTitle(e.target.value)}
              />
              
              <Textarea
                placeholder="Share your thoughts, questions, or experiences..."
                value={newPostContent}
                onChange={(e) => setNewPostContent(e.target.value)}
                className="min-h-[120px]"
              />
              
              <div className="flex items-center justify-between">
                <select
                  value={newPostCategory}
                  onChange={(e) => setNewPostCategory(e.target.value)}
                  className="bg-background border rounded-md px-3 py-1 text-sm"
                >
                  {categoryOptions.slice(1).map((option) => (
                    <option key={option.value} value={option.value}>
                      {option.label}
                    </option>
                  ))}
                </select>
                
                <Button 
                  onClick={handleCreatePost}
                  disabled={createPostMutation.isPending}
                >
                  Post
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
      
      {posts.length === 0 ? (
        <Card className="p-6 text-center">
          <Clock className="mx-auto h-8 w-8 text-muted-foreground mb-2" />
          <h3 className="font-medium">No posts yet</h3>
          <p className="text-sm text-muted-foreground mb-4">
            Be the first to share your thoughts with the community
          </p>
          <Button onClick={() => setShowNewPostForm(true)}>Create a Post</Button>
        </Card>
      ) : (
        <div className="space-y-4">
          {posts.map((post) => (
            <Card 
              key={post.id} 
              className="hover:shadow-md transition-shadow cursor-pointer"
              onClick={() => setSelectedPost(post)}
            >
              <CardContent className="p-4">
                <div className="flex items-start gap-3">
                  <Avatar className="h-10 w-10">
                    {post.userAvatar ? (
                      <AvatarImage src={post.userAvatar} alt={post.userName} />
                    ) : (
                      <AvatarFallback>{getInitials(post.userName)}</AvatarFallback>
                    )}
                  </Avatar>
                  
                  <div className="flex-1">
                    <h3 className="font-medium line-clamp-2">{post.title}</h3>
                    
                    <div className="flex items-center gap-2 text-xs text-muted-foreground mt-1">
                      <span>{post.userName}</span>
                      <span>•</span>
                      <span>{formatTimestamp(post.timestamp)}</span>
                      {post.category !== "General" && (
                        <>
                          <span>•</span>
                          <Badge variant="outline" className="text-xs">
                            {post.category}
                          </Badge>
                        </>
                      )}
                    </div>
                    
                    <p className="text-sm mt-2 line-clamp-2">{post.content}</p>
                    
                    <div className="flex items-center gap-4 mt-3">
                      <Button
                        variant="ghost"
                        size="sm"
                        className="flex items-center gap-1 p-0 h-8"
                        onClick={(e) => {
                          e.stopPropagation();
                          handleLikePost(post);
                        }}
                      >
                        <ThumbsUp className={`h-4 w-4 ${post.userLiked ? "fill-current text-primary" : ""}`} />
                        <span>{post.likes}</span>
                      </Button>
                      
                      <div className="flex items-center gap-1 text-muted-foreground">
                        <MessageSquare className="h-4 w-4" />
                        <span>{post.comments}</span>
                      </div>
                      
                      <Button
                        variant="ghost"
                        size="sm"
                        className="ml-auto p-0 h-8"
                        onClick={(e) => {
                          e.stopPropagation();
                          handleBookmarkPost(post);
                        }}
                      >
                        {post.userBookmarked ? (
                          <BookmarkCheck className="h-4 w-4 fill-current text-primary" />
                        ) : (
                          <BookmarkPlus className="h-4 w-4" />
                        )}
                      </Button>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}