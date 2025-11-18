-- SQL policies for `profiles` and `entries` tables

-- Enable row level security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entries ENABLE ROW LEVEL SECURITY;

-- profiles: allow users to insert their own profile linked to auth
CREATE POLICY "profiles_insert_owner" ON public.profiles
FOR INSERT USING (true) WITH CHECK (auth.uid() = user_id::text OR auth.role() = 'service_role');

-- profiles: allow users to select/update their own profile
CREATE POLICY "profiles_select" ON public.profiles
FOR SELECT USING (auth.uid() = user_id::text OR auth.role() = 'service_role');

CREATE POLICY "profiles_update_owner" ON public.profiles
FOR UPDATE USING (auth.uid() = user_id::text OR auth.role() = 'service_role') WITH CHECK (auth.uid() = user_id::text OR auth.role() = 'service_role');

-- entries: insert by authenticated users (user_id must match)
CREATE POLICY "entries_insert_owner" ON public.entries
FOR INSERT USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() = user_id::text OR auth.role() = 'service_role');

-- entries: select own entries (psychologists may have broader access depending on app logic)
CREATE POLICY "entries_select_owner" ON public.entries
FOR SELECT USING (auth.uid() = user_id::text OR auth.role() = 'service_role');

-- entries: update/delete own entries
CREATE POLICY "entries_modify_owner" ON public.entries
FOR UPDATE, DELETE USING (auth.uid() = user_id::text OR auth.role() = 'service_role') WITH CHECK (auth.uid() = user_id::text OR auth.role() = 'service_role');

-- Note: adjust policies to suit your app's sharing rules. service_role can be used for server-side operations.
