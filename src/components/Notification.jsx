import React, { useEffect } from 'react';

export default function Notification({ message, type, onClose }) {
  useEffect(() => {
    if (message) {
      const timer = setTimeout(() => {
        onClose();
      }, 5000); // La notificación desaparecerá después de 5 segundos

      return () => clearTimeout(timer);
    }
  }, [message, onClose]);

  if (!message) {
    return null;
  }

  const baseClasses = "fixed top-5 right-5 p-4 rounded-lg shadow-lg text-white transition-transform transform animate-fade-in-down";
  const typeClasses = {
    success: "bg-green-500",
    error: "bg-red-500",
    info: "bg-blue-500",
  };

  return (
    <div className={`${baseClasses} ${typeClasses[type] || typeClasses.info}`}>
      <span>{message}</span>
      <button onClick={onClose} className="ml-4 font-bold opacity-70 hover:opacity-100">X</button>
    </div>
  );
}

