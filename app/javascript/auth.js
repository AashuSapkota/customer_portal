document.addEventListener('DOMContentLoaded', function() {
    // Handle login form submission via AJAX if needed
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
      loginForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        fetch('/api/v1/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({
            email: this.email.value,
            password: this.password.value
          })
        })
        .then(response => response.json())
        .then(data => {
          if (data.token) {
            localStorage.setItem('authToken', data.token);
            window.location.href = '/';
          } else {
            showAlert('Invalid credentials', 'danger');
          }
        });
      });
    }
  });
  
  function showAlert(message, type) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type}`;
    alertDiv.textContent = message;
    
    const container = document.querySelector('.container');
    container.prepend(alertDiv);
    
    setTimeout(() => alertDiv.remove(), 5000);
  }