-- SQL Script to set up ScaleBook Database in Supabase
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard/project/_/sql)

-- 1. PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  firstName TEXT,
  hasCompletedOnboarding BOOLEAN DEFAULT FALSE,
  isPro BOOLEAN DEFAULT FALSE,
  createdAt TIMESTAMPTZ DEFAULT NOW(),
  updatedAt TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- 2. PROJECTS TABLE
CREATE TABLE IF NOT EXISTS public.projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  userId UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  scale TEXT NOT NULL,
  progress FLOAT DEFAULT 0.0,
  status TEXT NOT NULL,
  mainImageUrl TEXT,
  galleryUrls TEXT[] DEFAULT '{}',
  createdAt TIMESTAMPTZ DEFAULT NOW(),
  updatedAt TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for projects
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own projects" 
ON public.projects FOR ALL 
USING (auth.uid() = userId);

-- 3. BUILD STEPS TABLE
CREATE TABLE IF NOT EXISTS public.build_steps (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  projectId UUID REFERENCES public.projects ON DELETE CASCADE NOT NULL,
  userId UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  note TEXT NOT NULL,
  imageUrl TEXT,
  createdAt TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for build steps
ALTER TABLE public.build_steps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own build steps" 
ON public.build_steps FOR ALL 
USING (auth.uid() = userId);

-- 4. STORAGE BUCKET
-- Run these in your Storage dashboard:
-- Create a bucket named 'models' and make it public or use RLS.
-- Example RLS for storage:
-- CREATE POLICY "Users can upload their own images" 
-- ON storage.objects FOR INSERT 
-- WITH CHECK (bucket_id = 'models' AND auth.uid()::text = (storage.foldername(name))[1]);
