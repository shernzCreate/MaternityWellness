import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { AppLayout } from "@/components/app-layout";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { ResourceCard } from "@/components/resource-card";
import { Search } from "lucide-react";

interface Resource {
  id: number;
  title: string;
  description: string;
  category: string;
  readTime: number;
  type: string;
  featured?: boolean;
}

interface Category {
  id: string;
  name: string;
}

export default function ResourcesPage() {
  const [activeCategory, setActiveCategory] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState<string>("");

  // Fetch resources
  const { data, isLoading } = useQuery({
    queryKey: ["/api/resources"],
    queryFn: async () => {
      const res = await fetch("/api/resources");
      if (!res.ok) throw new Error("Failed to fetch resources");
      return res.json();
    }
  });

  const resources: Resource[] = data?.resources || [];
  const categories: Category[] = data?.categories || [];

  // Filter resources by category and search query
  const filteredResources = resources.filter((resource) => {
    const matchesCategory = activeCategory === "all" || resource.category === activeCategory;
    const matchesSearch = searchQuery === "" || 
      resource.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      resource.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  // Get featured resource
  const featuredResource = resources.find(r => r.featured);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    // Search is already handled via state
  };

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
      
      {/* Category Tabs */}
      <div className="px-4 pt-6 pb-3">
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
      </div>
      
      {/* Featured Resource */}
      {featuredResource && (
        <div className="px-4 mb-6">
          <ResourceCard 
            resource={featuredResource}
            isFeatured
          />
        </div>
      )}
      
      {/* Resources List */}
      <div className="px-4 pb-20">
        <h2 className="font-semibold text-lg mb-4">
          {isLoading ? "Loading resources..." : 
            filteredResources.length > 0 ? "Popular Resources" : "No resources found"}
        </h2>
        
        <div className="space-y-4">
          {filteredResources
            .filter(r => !r.featured) // Don't show featured resource again
            .map((resource) => (
              <ResourceCard 
                key={resource.id}
                resource={resource}
                isCompact
              />
            ))}
        </div>
        
        {!isLoading && filteredResources.length > 5 && (
          <Button 
            variant="ghost" 
            className="w-full text-primary font-medium text-center py-4 mt-4"
          >
            View All Resources
          </Button>
        )}
      </div>
    </AppLayout>
  );
}
