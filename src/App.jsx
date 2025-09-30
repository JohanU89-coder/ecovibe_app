import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/LoginPage.jsx';
import WastePortalPage from './pages/WastePortalPage.jsx';
import WaterPortalPage from './pages/WaterPortalPage.jsx';
import PlngWastePortalPage from './pages/PlngWastePortalPage.jsx';
import DashboardPage from './pages/DashboardPage.jsx';
import Layout from './components/Layout.jsx';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<LoginPage />} />
        <Route path="/portal" element={<Layout />}>
          <Route index element={<Navigate to="dashboard" replace />} /> 
          <Route path="dashboard" element={<DashboardPage />} />
          <Route path="residuos" element={<WastePortalPage />} />
          <Route path="residuos-plng" element={<PlngWastePortalPage />} />
          <Route path="agua" element={<WaterPortalPage />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;

