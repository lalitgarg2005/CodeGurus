'use client';

import { useUser, SignInButton, SignUpButton } from '@clerk/nextjs';
import Link from 'next/link';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
  const { isSignedIn, user, isLoaded } = useUser();
  const router = useRouter();

  // Don't auto-redirect - let users navigate manually
  // This prevents flashing when clicking Home button

  return (
    <div className="min-h-screen bg-white">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-lg shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <Link href={isSignedIn ? "/dashboard" : "/"} className="flex items-center gap-2 hover:opacity-80 transition-opacity">
            <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
              <span className="text-white font-bold text-xl">L</span>
            </div>
            <h1 className="text-2xl font-bold gradient-text">Learn Together</h1>
          </Link>
          <div className="flex gap-2">
            {!isSignedIn ? (
              <>
                <SignInButton mode="modal">
                  <button className="btn btn-outline text-sm px-3 py-1.5">Sign In</button>
                </SignInButton>
                <SignUpButton mode="modal">
                  <button className="btn btn-primary text-sm px-3 py-1.5">Get Started</button>
                </SignUpButton>
              </>
            ) : (
              <>
                <Link href="/volunteer-signup">
                  <button className="btn btn-outline text-xs px-3 py-1.5">Volunteer</button>
                </Link>
                <Link href="/parent-signup">
                  <button className="btn btn-outline text-xs px-3 py-1.5">Parent</button>
                </Link>
              </>
            )}
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-4 bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50 relative overflow-hidden">
        <div className="absolute inset-0 overflow-hidden">
          <div className="absolute -top-40 -right-40 w-80 h-80 bg-purple-300 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-float"></div>
          <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-pink-300 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-float" style={{ animationDelay: '2s' }}></div>
          <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-80 h-80 bg-blue-300 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-float" style={{ animationDelay: '4s' }}></div>
        </div>
        <div className="container mx-auto text-center relative z-10">
          <div className="animate-fade-in-up">
            <h2 className="text-6xl md:text-7xl font-bold mb-6 leading-tight">
              <span className="gradient-text">Empower Learning</span>
              <br />
              <span className="text-gray-800">Together</span>
            </h2>
            <p className="text-xl md:text-2xl text-gray-600 mb-8 max-w-2xl mx-auto">
              A safe, nonprofit platform connecting passionate volunteers with eager students. 
              Building knowledge, one session at a time.
            </p>
          </div>
          
          {/* Hero Image Placeholder */}
          <div className="mt-16 animate-fade-in" style={{ animationDelay: '0.3s' }}>
            <div className="relative max-w-4xl mx-auto">
              <div className="bg-gradient-to-br from-purple-400 to-pink-400 rounded-3xl p-8 shadow-2xl transform rotate-1">
                <div className="bg-white rounded-2xl p-12 text-center">
                  <div className="grid grid-cols-3 gap-4 mb-6">
                    <div className="bg-gradient-to-br from-blue-100 to-blue-200 rounded-xl p-6">
                      <div className="text-4xl mb-2">📚</div>
                      <div className="text-sm font-semibold text-blue-800">Skills</div>
                    </div>
                    <div className="bg-gradient-to-br from-purple-100 to-purple-200 rounded-xl p-6">
                      <div className="text-4xl mb-2">👥</div>
                      <div className="text-sm font-semibold text-purple-800">Sessions</div>
                    </div>
                    <div className="bg-gradient-to-br from-pink-100 to-pink-200 rounded-xl p-6">
                      <div className="text-4xl mb-2">🎥</div>
                      <div className="text-sm font-semibold text-pink-800">Videos</div>
                    </div>
                  </div>
                  <p className="text-gray-600">Interactive learning platform for students of all ages</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="section">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16 animate-fade-in-up">
            <h3 className="text-4xl md:text-5xl font-bold mb-4">
              <span className="gradient-text">Why Choose</span> Learn Together?
            </h3>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              We've built a platform that prioritizes safety, quality, and meaningful connections
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <div className="card text-center animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
              <div className="w-20 h-20 bg-gradient-to-br from-blue-400 to-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                <span className="text-4xl">🎓</span>
              </div>
              <h4 className="text-2xl font-bold mb-4 gradient-text-3">For Students</h4>
              <p className="text-gray-600 mb-6">
                Learn new skills from passionate volunteers in a safe, supervised environment
              </p>
              <ul className="text-left text-sm text-gray-600 space-y-3">
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Age-appropriate content</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Parent-supervised enrollment</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Interactive learning sessions</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Access to educational videos</span>
                </li>
              </ul>
            </div>

            <div className="card text-center animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
              <div className="w-20 h-20 bg-gradient-to-br from-purple-400 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                <span className="text-4xl">💜</span>
              </div>
              <h4 className="text-2xl font-bold mb-4 gradient-text">For Volunteers</h4>
              <p className="text-gray-600 mb-6">
                Share your expertise and make a real difference in students' lives
              </p>
              <ul className="text-left text-sm text-gray-600 space-y-3">
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Create skills and sessions</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Upload educational videos</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Admin-approved accounts</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Flexible scheduling</span>
                </li>
              </ul>
            </div>

            <div className="card text-center animate-fade-in-up" style={{ animationDelay: '0.3s' }}>
              <div className="w-20 h-20 bg-gradient-to-br from-pink-400 to-pink-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                <span className="text-4xl">👨‍👩‍👧</span>
              </div>
              <h4 className="text-2xl font-bold mb-4 gradient-text-2">For Parents</h4>
              <p className="text-gray-600 mb-6">
                Manage your children's learning journey with full visibility and control
              </p>
              <ul className="text-left text-sm text-gray-600 space-y-3">
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Register and manage students</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Enroll in sessions</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>View all content</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="text-green-500 text-xl">✓</span>
                  <span>Monitor progress</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="section section-alt">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8 text-center">
            <div className="animate-fade-in-up">
              <div className="text-5xl font-bold gradient-text mb-2">500+</div>
              <div className="text-gray-600 font-semibold">Active Students</div>
            </div>
            <div className="animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
              <div className="text-5xl font-bold gradient-text-2 mb-2">100+</div>
              <div className="text-gray-600 font-semibold">Volunteers</div>
            </div>
            <div className="animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
              <div className="text-5xl font-bold gradient-text-3 mb-2">50+</div>
              <div className="text-gray-600 font-semibold">Skills Available</div>
            </div>
            <div className="animate-fade-in-up" style={{ animationDelay: '0.3s' }}>
              <div className="text-5xl font-bold gradient-text mb-2">1000+</div>
              <div className="text-gray-600 font-semibold">Sessions Completed</div>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="section">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h3 className="text-4xl md:text-5xl font-bold mb-4">
              <span className="gradient-text">How It Works</span>
            </h3>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Getting started is simple and safe
            </p>
          </div>

          <div className="grid md:grid-cols-4 gap-8">
            {[
              { step: '1', title: 'Sign Up', desc: 'Choose your role: Volunteer, Parent, or Admin', icon: '📝', color: 'from-blue-400 to-blue-600' },
              { step: '2', title: 'Get Approved', desc: 'Volunteers are reviewed by admins for safety', icon: '✅', color: 'from-green-400 to-green-600' },
              { step: '3', title: 'Create & Learn', desc: 'Volunteers create sessions, parents enroll students', icon: '🚀', color: 'from-purple-400 to-purple-600' },
              { step: '4', title: 'Grow Together', desc: 'Track progress and continue learning', icon: '📈', color: 'from-pink-400 to-pink-600' },
            ].map((item, idx) => (
              <div key={idx} className="text-center animate-fade-in-up" style={{ animationDelay: `${idx * 0.1}s` }}>
                <div className={`w-24 h-24 bg-gradient-to-br ${item.color} rounded-3xl flex items-center justify-center mx-auto mb-6 shadow-lg`}>
                  <span className="text-5xl">{item.icon}</span>
                </div>
                <div className="text-3xl font-bold text-gray-300 mb-2">{item.step}</div>
                <h4 className="text-xl font-bold mb-3">{item.title}</h4>
                <p className="text-gray-600">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Safety Section */}
      <section className="section section-alt">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-12">
              <div className="w-24 h-24 bg-gradient-to-br from-red-400 to-red-600 rounded-3xl flex items-center justify-center mx-auto mb-6">
                <span className="text-5xl">🛡️</span>
              </div>
              <h3 className="text-4xl md:text-5xl font-bold mb-4">
                <span className="gradient-text-2">Safety First</span>
              </h3>
              <p className="text-xl text-gray-600">
                Your child's safety is our top priority
              </p>
            </div>

            <div className="grid md:grid-cols-2 gap-6">
              {[
                { icon: '📧', title: 'Parent Email Required', desc: 'All student accounts must be linked to a parent email for complete oversight' },
                { icon: '🚫', title: 'No Direct Messaging', desc: 'Students and volunteers cannot message each other directly' },
                { icon: '✅', title: 'Admin Approval', desc: 'All volunteers require admin approval before they can teach' },
                { icon: '👀', title: 'Session Supervision', desc: 'All sessions are linked to parent accounts for full visibility' },
              ].map((item, idx) => (
                <div key={idx} className="card animate-fade-in-up" style={{ animationDelay: `${idx * 0.1}s` }}>
                  <div className="flex items-start gap-4">
                    <div className="text-4xl">{item.icon}</div>
                    <div>
                      <h4 className="text-xl font-bold mb-2">{item.title}</h4>
                      <p className="text-gray-600">{item.desc}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="section bg-gradient-to-br from-purple-600 via-pink-600 to-blue-600 text-white">
        <div className="container mx-auto px-4 text-center">
          <div className="max-w-3xl mx-auto animate-fade-in-up">
            <h3 className="text-4xl md:text-5xl font-bold mb-6">
              Ready to Start Learning?
            </h3>
            <p className="text-xl mb-8 opacity-90">
              Join our community of learners and educators today. 
              It's free, safe, and designed to make a difference.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              {!isSignedIn ? (
                <SignUpButton mode="modal">
                  <button className="btn bg-white text-purple-600 hover:bg-gray-100 text-lg px-8 py-4">
                    Get Started Free
                  </button>
                </SignUpButton>
              ) : (
                <Link href="/dashboard">
                  <button className="btn bg-white text-purple-600 hover:bg-gray-100 text-lg px-8 py-4">
                    Go to Dashboard
                  </button>
                </Link>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
                  <span className="text-white font-bold text-xl">L</span>
                </div>
                <h4 className="text-xl font-bold">Learn Together</h4>
              </div>
              <p className="text-gray-400">
                Empowering education through volunteer-driven learning.
              </p>
            </div>
            <div>
              <h5 className="font-bold mb-4">For Students</h5>
              <ul className="space-y-2 text-gray-400">
                <li>Browse Skills</li>
                <li>Join Sessions</li>
                <li>Watch Videos</li>
              </ul>
            </div>
            <div>
              <h5 className="font-bold mb-4">For Volunteers</h5>
              <ul className="space-y-2 text-gray-400">
                <li>Create Skills</li>
                <li>Schedule Sessions</li>
                <li>Upload Videos</li>
              </ul>
            </div>
            <div>
              <h5 className="font-bold mb-4">For Parents</h5>
              <ul className="space-y-2 text-gray-400">
                <li>Manage Students</li>
                <li>Enroll in Sessions</li>
                <li>Track Progress</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 pt-8 text-center text-gray-400">
            <p>&copy; 2024 Learn Together. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
