-- SQL Script to set up ScaleBook Database in Supabase
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard/project/_/sql)

-- 1. PROFILES TABLE
-- Stores user-specific settings and onboarding status
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  first_name TEXT,
  has_completed_onboarding BOOLEAN DEFAULT FALSE,
  is_pro BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
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
-- Stores model building projects
CREATE TABLE IF NOT EXISTS public.projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  scale TEXT NOT NULL,
  progress FLOAT DEFAULT 0.0,
  status TEXT NOT NULL,
  main_image_url TEXT,
  gallery_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for projects
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own projects" 
ON public.projects FOR ALL 
USING (auth.uid() = user_id);

-- 3. BUILD STEPS TABLE
-- Stores history of building steps for each project
CREATE TABLE IF NOT EXISTS public.build_steps (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID REFERENCES public.projects ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  note TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for build steps
ALTER TABLE public.build_steps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own build steps" 
ON public.build_steps FOR ALL 
USING (auth.uid() = user_id);

-- 4. STORAGE BUCKET
-- Run these in your Storage dashboard:
-- Create a bucket named 'models' and make it public or use RLS.
-- Example RLS for storage:
-- CREATE POLICY "Users can upload their own images" 
-- ON storage.objects FOR INSERT 
-- WITH CHECK (bucket_id = 'models' AND auth.uid()::text = (storage.foldername(name))[1]);
