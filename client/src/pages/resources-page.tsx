import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { AppLayout } from "@/components/app-layout";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ResourceCard } from "@/components/resource-card";
import { ResourceDetail } from "@/components/resource-detail";
import { Search, BookmarkCheck, Clock, Filter, ChevronDown } from "lucide-react";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { 
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useAuth } from "@/hooks/use-auth";
import { isInNativeApp } from "@/lib/nativeBridge";

interface Resource {
  id: number;
  title: string;
  description: string;
  category: string;
  readTime: number;
  type: string;
  content?: string;
  author?: string;
  publishDate?: string;
  featured?: boolean;
  tags?: string[];
  sourceUrl?: string;
  relatedIds?: number[];
}

interface Category {
  id: string;
  name: string;
}

interface ResourceProgress {
  resourceId: number;
  progress: number;
  completed: boolean;
  lastViewed: string;
}

export default function ResourcesPage() {
  const { user } = useAuth();
  const [activeCategory, setActiveCategory] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [selectedResourceId, setSelectedResourceId] = useState<number | null>(null);
  const [sortBy, setSortBy] = useState<"recent" | "popular" | "shortest">("recent");
  const [filterTag, setFilterTag] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<"all" | "saved" | "completed">("all");
  
  // Is running in native app
  const isNative = isInNativeApp();

  // Fetch resources
  const { data, isLoading } = useQuery({
    queryKey: ["/api/resources"],
    queryFn: async () => {
      const res = await fetch("/api/resources");
      if (!res.ok) throw new Error("Failed to fetch resources");
      return res.json();
    }
  });

  // Fetch user's bookmarked resources
  const { data: bookmarksData } = useQuery({
    queryKey: ["/api/resources/bookmarks"],
    queryFn: async () => {
      if (!user) return { bookmarks: [] };
      const res = await fetch("/api/resources/bookmarks");
      if (!res.ok) return { bookmarks: [] };
      return res.json();
    },
    enabled: !!user
  });

  // Fetch user's resource progress
  const { data: progressData } = useQuery({
    queryKey: ["/api/resources/progress"],
    queryFn: async () => {
      if (!user) return { progress: [] };
      const res = await fetch("/api/resources/progress");
      if (!res.ok) return { progress: [] };
      return res.json();
    },
    enabled: !!user
  });

  const resources: Resource[] = data?.resources || [];
  const categories: Category[] = data?.categories || [];
  const bookmarkedIds: number[] = bookmarksData?.bookmarks?.map((b: any) => b.resourceId) || [];
  const resourceProgress: ResourceProgress[] = progressData?.progress || [];
  
  // Get unique tags from all resources
  const allTags = resources.reduce((tags: string[], resource) => {
    if (resource.tags) {
      resource.tags.forEach(tag => {
        if (!tags.includes(tag)) {
          tags.push(tag);
        }
      });
    }
    return tags;
  }, []);

  // Filter resources based on active filters and search
  const getFilteredResources = () => {
    // First filter by category and search
    let filtered = resources.filter((resource) => {
      const matchesCategory = activeCategory === "all" || resource.category === activeCategory;
      const matchesSearch = searchQuery === "" || 
        resource.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        resource.description.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesTag = !filterTag || (resource.tags && resource.tags.includes(filterTag));
      return matchesCategory && matchesSearch && matchesTag;
    });
    
    // Then filter by tab selection
    if (activeTab === "saved") {
      filtered = filtered.filter(resource => bookmarkedIds.includes(resource.id));
    } else if (activeTab === "completed") {
      const completedIds = resourceProgress
        .filter(prog => prog.completed)
        .map(prog => prog.resourceId);
      filtered = filtered.filter(resource => completedIds.includes(resource.id));
    }
    
    // Sort resources
    return filtered.sort((a, b) => {
      if (sortBy === "recent") {
        const dateA = a.publishDate ? new Date(a.publishDate) : new Date(0);
        const dateB = b.publishDate ? new Date(b.publishDate) : new Date(0);
        return dateB.getTime() - dateA.getTime(); // newest first
      } else if (sortBy === "shortest") {
        return a.readTime - b.readTime; // shortest first
      } else {
        return b.id - a.id; // assuming higher id means more popular
      }
    });
  };

  const filteredResources = getFilteredResources();
  
  // Get featured resource (only show on "all" tab)
  const featuredResource = activeTab === "all" ? resources.find(r => r.featured) : undefined;
  
  // Selected resource for detailed view
  const selectedResource = resources.find(r => r.id === selectedResourceId);
  
  // Get progress for a resource
  const getResourceProgress = (resourceId: number): number => {
    const progress = resourceProgress.find(p => p.resourceId === resourceId);
    return progress?.progress || 0;
  };
  
  // Is resource bookmarked
  const isBookmarked = (resourceId: number): boolean => {
    return bookmarkedIds.includes(resourceId);
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    // Search is already handled via state
  };
  
  const handleResourceClick = (id: number) => {
    setSelectedResourceId(id);
  };
  
  const handleBackFromDetail = () => {
    setSelectedResourceId(null);
  };

  // If we're viewing a resource detail
  if (selectedResource) {
    return (
      <ResourceDetail
        id={selectedResource.id}
        title={selectedResource.title}
        description={selectedResource.description}
        category={selectedResource.category}
        readTime={selectedResource.readTime}
        type={selectedResource.type as "article" | "video"}
        content={selectedResource.content || "Content is loading..."}
        publishDate={selectedResource.publishDate || new Date().toISOString()}
        author={selectedResource.author}
        onClose={handleBackFromDetail}
      />
    );
  }

  return (
    <AppLayout activeTab="learn">
      <div className="bg-primary text-white px-4 py-6">
        <h1 className="font-bold text-xl mb-4">Resources & Education</h1>
        
        <form onSubmit={handleSearch} className="relative">
          <Input 
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search resources..." 
            className="w-full bg-white bg-opacity-20 rounded-lg border border-white border-opacity-20 px-4 py-3 text-white placeholder-white placeholder-opacity-60 focus:outline-none"
          />
          <Button 
            type="submit"
            variant="ghost" 
            size="icon" 
            className="absolute right-2 top-1/2 transform -translate-y-1/2 text-white hover:bg-transparent"
          >
            <Search className="h-5 w-5" />
          </Button>
        </form>
      </div>
      
      {/* Tabs and Filters */}
      <div className="px-4 pt-4">
        <Tabs defaultValue="all" value={activeTab} onValueChange={(v) => setActiveTab(v as "all" | "saved" | "completed")}>
          <TabsList className="grid w-full grid-cols-3 mb-4">
            <TabsTrigger value="all">All</TabsTrigger>
            <TabsTrigger value="saved" disabled={!user}>
              <BookmarkCheck className="h-4 w-4 mr-2" />
              Saved
            </TabsTrigger>
            <TabsTrigger value="completed" disabled={!user}>
              <Clock className="h-4 w-4 mr-2" />
              Completed
            </TabsTrigger>
          </TabsList>
          
          <div className="flex items-center justify-between mb-4">
            <div className="flex space-x-2 overflow-x-auto pb-1 flex-1">
              {/* Category buttons (show limited on mobile) */}
              {isNative ? (
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" size="sm" className="flex items-center">
                      {activeCategory === "all" ? "All Categories" : 
                        categories.find(c => c.id === activeCategory)?.name || "Categories"}
                      <ChevronDown className="ml-2 h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="start">
                    {categories.map((category) => (
                      <DropdownMenuItem 
                        key={category.id}
                        onClick={() => setActiveCategory(category.id)}
                      >
                        {category.name}
                      </DropdownMenuItem>
                    ))}
                  </DropdownMenuContent>
                </DropdownMenu>
              ) : (
                <div className="flex space-x-2 overflow-x-auto pb-2 -mx-1 px-1">
                  {categories.map((category) => (
                    <Button
                      key={category.id}
                      variant={activeCategory === category.id ? "default" : "outline"}
                      size="sm"
                      className="whitespace-nowrap flex-shrink-0"
                      onClick={() => setActiveCategory(category.id)}
                    >
                      {category.name}
                    </Button>
                  ))}
                </div>
              )}
            </div>
            
            {/* Filters dropdown */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm">
                  <Filter className="h-4 w-4 mr-2" />
                  Filter
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem 
                  onClick={() => setSortBy("recent")}
                  className={sortBy === "recent" ? "bg-muted" : ""}
                >
                  Most Recent
                </DropdownMenuItem>
                <DropdownMenuItem 
                  onClick={() => setSortBy("popular")}
                  className={sortBy === "popular" ? "bg-muted" : ""}
                >
                  Most Popular
                </DropdownMenuItem>
                <DropdownMenuItem 
                  onClick={() => setSortBy("shortest")}
                  className={sortBy === "shortest" ? "bg-muted" : ""}
                >
                  Shortest First
                </DropdownMenuItem>
                
                {allTags.length > 0 && (
                  <>
                    <div className="px-2 py-1.5 text-sm font-semibold">Tags</div>
                    {allTags.map(tag => (
                      <DropdownMenuItem 
                        key={tag}
                        onClick={() => setFilterTag(filterTag === tag ? null : tag)}
                        className={filterTag === tag ? "bg-muted" : ""}
                      >
                        {tag}
                      </DropdownMenuItem>
                    ))}
                  </>
                )}
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
          
          <TabsContent value="all" className="mt-0">
            {/* Featured Resource */}
            {featuredResource && (
              <div className="mb-6">
                <div className="mb-2 flex items-center justify-between">
                  <h2 className="font-semibold text-lg">Featured</h2>
                  {isBookmarked(featuredResource.id) && (
                    <Badge variant="outline" className="flex items-center">
                      <BookmarkCheck className="h-3 w-3 mr-1" />
                      Saved
                    </Badge>
                  )}
                </div>
                <div onClick={() => handleResourceClick(featuredResource.id)}>
                  <ResourceCard 
                    resource={featuredResource}
                    isFeatured
                  />
                </div>
                
                {user && getResourceProgress(featuredResource.id) > 0 && (
                  <div className="mt-2">
                    <div className="flex justify-between text-xs text-muted-foreground mb-1">
                      <span>Reading progress</span>
                      <span>{getResourceProgress(featuredResource.id)}%</span>
                    </div>
                    <Progress value={getResourceProgress(featuredResource.id)} className="h-1" />
                  </div>
                )}
              </div>
            )}
            
            {/* Singapore Local Resources Section */}
            <div className="mb-6">
              <h2 className="font-semibold text-lg mb-2">Singapore Resources</h2>
              <p className="text-sm text-muted-foreground mb-3">Local support services and information</p>
              <div className="space-y-3">
                {filteredResources
                  .filter(r => r.tags?.includes('singapore'))
                  .slice(0, 3)
                  .map((resource) => (
                    <div key={resource.id} onClick={() => handleResourceClick(resource.id)}>
                      <ResourceCard 
                        resource={resource}
                        isCompact
                      />
                      {user && getResourceProgress(resource.id) > 0 && (
                        <div className="mt-1">
                          <Progress value={getResourceProgress(resource.id)} className="h-1" />
                        </div>
                      )}
                    </div>
                  ))}
                
                {filteredResources.filter(r => r.tags?.includes('singapore')).length === 0 && (
                  <Card>
                    <CardContent className="p-3 text-center text-muted-foreground text-sm">
                      No Singapore-specific resources found with the current filters.
                    </CardContent>
                  </Card>
                )}
              </div>
            </div>
            
            {/* All Resources List */}
            <h2 className="font-semibold text-lg mb-3">
              {isLoading ? "Loading resources..." : 
                filteredResources.length > 0 ? "All Resources" : "No resources found"}
            </h2>
            
            {isLoading ? (
              // Loading skeletons
              <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                  <Card key={i}>
                    <CardContent className="p-3 flex">
                      <Skeleton className="w-20 h-20 rounded mr-3" />
                      <div className="flex-1">
                        <Skeleton className="h-5 w-4/5 mb-2" />
                        <Skeleton className="h-4 w-full mb-2" />
                        <Skeleton className="h-4 w-2/3" />
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            ) : (
              <div className="space-y-3 pb-20">
                {filteredResources
                  .filter(r => !r.featured) // Don't show featured resource again
                  .map((resource) => (
                    <div key={resource.id}>
                      <div onClick={() => handleResourceClick(resource.id)}>
                        <ResourceCard 
                          resource={resource}
                          isCompact
                        />
                      </div>
                      {user && getResourceProgress(resource.id) > 0 && (
                        <div className="mt-1">
                          <Progress value={getResourceProgress(resource.id)} className="h-1" />
                        </div>
                      )}
                    </div>
                  ))}
                
                {filteredResources.length === 0 && (
                  <Card>
                    <CardContent className="p-6 text-center">
                      <p className="text-muted-foreground mb-3">No resources found matching your filters</p>
                      <Button onClick={() => {
                        setActiveCategory("all");
                        setSearchQuery("");
                        setFilterTag(null);
                      }}>
                        Clear Filters
                      </Button>
                    </CardContent>
                  </Card>
                )}
              </div>
            )}
          </TabsContent>
          
          <TabsContent value="saved" className="mt-0">
            <h2 className="font-semibold text-lg mb-3">Saved Resources</h2>
            {!user ? (
              <Card>
                <CardContent className="p-6 text-center">
                  <p className="text-muted-foreground mb-3">Sign in to save resources</p>
                  <Button>Sign In</Button>
                </CardContent>
              </Card>
            ) : filteredResources.length === 0 ? (
              <Card>
                <CardContent className="p-6 text-center">
                  <p className="text-muted-foreground mb-3">You haven't saved any resources yet</p>
                  <Button onClick={() => setActiveTab("all")}>Browse Resources</Button>
                </CardContent>
              </Card>
            ) : (
              <div className="space-y-3 pb-20">
                {filteredResources.map((resource) => (
                  <div key={resource.id}>
                    <div onClick={() => handleResourceClick(resource.id)}>
                      <ResourceCard 
                        resource={resource}
                        isCompact
                      />
                    </div>
                    {getResourceProgress(resource.id) > 0 && (
                      <div className="mt-1">
                        <Progress value={getResourceProgress(resource.id)} className="h-1" />
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </TabsContent>
          
          <TabsContent value="completed" className="mt-0">
            <h2 className="font-semibold text-lg mb-3">Completed Resources</h2>
            {!user ? (
              <Card>
                <CardContent className="p-6 text-center">
                  <p className="text-muted-foreground mb-3">Sign in to track completed resources</p>
                  <Button>Sign In</Button>
                </CardContent>
              </Card>
            ) : filteredResources.length === 0 ? (
              <Card>
                <CardContent className="p-6 text-center">
                  <p className="text-muted-foreground mb-3">You haven't completed any resources yet</p>
                  <Button onClick={() => setActiveTab("all")}>Browse Resources</Button>
                </CardContent>
              </Card>
            ) : (
              <div className="space-y-3 pb-20">
                {filteredResources.map((resource) => (
                  <div key={resource.id} onClick={() => handleResourceClick(resource.id)}>
                    <ResourceCard 
                      resource={resource}
                      isCompact
                    />
                  </div>
                ))}
              </div>
            )}
          </TabsContent>
        </Tabs>
      </div>
    </AppLayout>
  );
}
