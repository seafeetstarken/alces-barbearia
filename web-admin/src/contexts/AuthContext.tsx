import React, { createContext, useContext, useEffect, useState } from 'react';
import { User, Session } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase/client';
import type { Profile, UserRole } from '@/lib/supabase/types';

interface AuthContextType {
    user: User | null;
    profile: Profile | null;
    session: Session | null;
    role: UserRole | null;
    isLoading: boolean;
    signIn: (email: string, password: string) => Promise<{ error: Error | null; role?: UserRole | null }>;
    signOut: () => Promise<void>;
    isOwner: boolean;
    isManager: boolean;
    isLeader: boolean;
    isBarber: boolean;
    isSuperAdmin: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
    const [user, setUser] = useState<User | null>(null);
    const [profile, setProfile] = useState<Profile | null>(null);
    const [session, setSession] = useState<Session | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        // Get initial session
        supabase.auth.getSession().then(({ data: { session } }) => {
            setSession(session);
            setUser(session?.user ?? null);
            if (session?.user) {
                fetchProfile(session.user.id);
            } else {
                setIsLoading(false);
            }
        }).catch(err => {
            console.error("Erro ao recuperar sessão (possível cache corrompido):", err);
            setIsLoading(false);
        });

        // Listen for auth changes
        const {
            data: { subscription },
        } = supabase.auth.onAuthStateChange(async (_event, session) => {
            setSession(session);
            setUser(session?.user ?? null);
            if (session?.user) {
                await fetchProfile(session.user.id);
            } else {
                setProfile(null);
                setIsLoading(false);
            }
        });

        return () => subscription.unsubscribe();
    }, []);

    async function fetchProfile(userId: string) {
        try {
            const { data, error } = await supabase
                .from('profiles')
                .select('*')
                .eq('id', userId)
                .single();

            if (error) throw error;
            setProfile(data as Profile);
        } catch (error) {
            console.error('Error fetching profile:', error);
            setProfile(null);
        } finally {
            setIsLoading(false);
        }
    }

    async function signIn(email: string, password: string) {
        try {
            const { data, error } = await supabase.auth.signInWithPassword({
                email,
                password,
            });
            if (error) throw error;
            
            let userRole: UserRole | null = (data.user?.user_metadata?.role as UserRole) ?? null;
            
            // Force state update immediately
            if (data.session) {
                setSession(data.session);
                setUser(data.user);
                
                try {
                    const { data: profileData, error: profileError } = await supabase
                        .from('profiles')
                        .select('*')
                        .eq('id', data.user.id)
                        .single();

                    if (!profileError && profileData) {
                        setProfile(profileData as Profile);
                        userRole = (profileData as Profile).role ?? userRole;
                    }
                } catch (err) {
                    console.error('Error fetching profile during signIn:', err);
                }
            }
            
            setIsLoading(false);
            
            return { error: null, role: userRole };
        } catch (error) {
            return { error: error as Error, role: null };
        }
    }

    async function signOut() {
        await supabase.auth.signOut();
        setUser(null);
        setProfile(null);
        setSession(null);
    }

    // Use profile.role, fallback to user_metadata.role
    const role = profile?.role ?? (user?.user_metadata?.role as UserRole) ?? null;

    const value: AuthContextType = {
        user,
        profile,
        session,
        role,
        isLoading,
        signIn,
        signOut,
        isOwner: role === 'owner',
        isManager: role === 'owner' || role === 'manager',
        isLeader: role === 'owner' || role === 'manager' || role === 'leader',
        isBarber: role === 'barber',
        isSuperAdmin: role === 'super_admin',
    };

    return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
    const context = useContext(AuthContext);
    if (context === undefined) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
}

export default AuthContext;
