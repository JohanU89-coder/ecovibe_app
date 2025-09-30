import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';

export default function Layout() {
  return (
    <div className="flex bg-gray-100">
      <Sidebar />
      <main className="flex-1 h-screen overflow-y-auto">
        <Outlet /> 
      </main>
    </div>
  );
}
