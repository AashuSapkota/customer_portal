// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('DOMContentLoaded', function() {
    // Initialize Bootstrap tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  
    // Check authentication
    checkAuth();
  
    // Navigation
    document.querySelectorAll('[data-page]').forEach(link => {
      link.addEventListener('click', function(e) {
        e.preventDefault();
        loadPage(this.getAttribute('data-page'));
      });
    });
  
    // Logout
    document.getElementById('logout-btn').addEventListener('click', logout);
  
    // Load initial page
    if (window.location.hash) {
      const page = window.location.hash.substring(1);
      loadPage(page);
    } else {
      loadPage('dashboard');
    }
  });
  
  // Check authentication
  function checkAuth() {
    const authToken = localStorage.getItem('authToken');
    if (!authToken) {
      window.location.href = '/login';
      return;
    }
  
    fetch('/api/v1/me', {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    })
    .then(response => {
      if (!response.ok) {
        logout();
        throw new Error('Not authenticated');
      }
      return response.json();
    })
    .then(data => {
      currentUser = data.user;
      updateUserUI();
    })
    .catch(error => {
      console.error('Authentication error:', error);
      logout();
    });
  }
  
  // Update UI with user info
  function updateUserUI() {
    if (currentUser) {
      document.getElementById('current-user-name').textContent = 
        `${currentUser.first_name} ${currentUser.last_name}`;
      const avatar = document.getElementById('user-avatar');
      avatar.textContent = 
        currentUser.first_name.charAt(0) + currentUser.last_name.charAt(0);
    }
  }
  
  // Logout
  function logout() {
    localStorage.removeItem('authToken');
    window.location.href = '/login';
  }
  
  // Load page content
  function loadPage(page) {
    window.location.hash = page;
    
    // Highlight active nav link
    document.querySelectorAll('[data-page]').forEach(link => {
      const navItem = link.closest('.nav-item');
      if (navItem) {
        navItem.classList.toggle('active', link.getAttribute('data-page') === page);
      }
    });
  
    // Load content
    const contentDiv = document.getElementById('content');
    contentDiv.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>';
    
    fetch(`/pages/${page}`)
      .then(response => response.text())
      .then(html => {
        contentDiv.innerHTML = html;
        initializePageScripts(page);
      })
      .catch(error => {
        contentDiv.innerHTML = `<div class="alert alert-danger">Error loading page: ${error.message}</div>`;
      });
  }
  
  // Initialize page-specific scripts
  function initializePageScripts(page) {
    switch(page) {
      case 'dashboard':
        loadDashboardData();
        break;
      case 'orders':
        if (document.getElementById('orders-table')) {
          initializeOrdersTable();
        } else if (document.getElementById('order-form')) {
          initializeOrderForm();
        }
        break;
      case 'vendors':
        if (document.getElementById('vendor-form')) {
          initializeVendorForm();
        }
        break;
      // Add other page initializations as needed
    }
  }
  
  // Dashboard data loading
  function loadDashboardData() {
    Promise.all([
      fetch('/api/v1/delivery_orders?limit=5').then(res => res.json()),
      fetch('/api/v1/contracts?status=active').then(res => res.json())
    ])
    .then(([orders, contracts]) => {
      // Update recent orders
      const ordersHtml = orders.length ? `
        <table class="table">
          <thead>
            <tr>
              <th>Order #</th>
              <th>Delivery Date</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            ${orders.map(order => `
              <tr>
                <td><a href="#order-detail" data-order-id="${order.id}">${order.order_number}</a></td>
                <td>${new Date(order.delivery_date).toLocaleDateString()}</td>
                <td><span class="badge bg-${statusBadgeClass(order.status)}">${order.status}</span></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      ` : '<p class="text-muted">No recent orders</p>';
      
      document.getElementById('recent-orders').innerHTML = ordersHtml;
      
      // Update contracts
      const contractsHtml = contracts.length ? `
        <table class="table">
          <thead>
            <tr>
              <th>Vendor</th>
              <th>Start Date</th>
              <th>End Date</th>
            </tr>
          </thead>
          <tbody>
            ${contracts.map(contract => `
              <tr>
                <td>${contract.vendor.name}</td>
                <td>${new Date(contract.start_date).toLocaleDateString()}</td>
                <td>${new Date(contract.end_date).toLocaleDateString()}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      ` : '<p class="text-muted">No active contracts</p>';
      
      document.getElementById('active-contracts').innerHTML = contractsHtml;
      
      // Add event listeners
      document.querySelectorAll('[data-order-id]').forEach(link => {
        link.addEventListener('click', function(e) {
          e.preventDefault();
          loadOrderDetail(this.getAttribute('data-order-id'));
        });
      });
    })
    .catch(error => {
      console.error('Error loading dashboard data:', error);
      document.getElementById('recent-orders').innerHTML = 
        '<div class="alert alert-danger">Error loading recent orders</div>';
      document.getElementById('active-contracts').innerHTML = 
        '<div class="alert alert-danger">Error loading contracts</div>';
    });
  }
  
  // Helper function for status badge classes
  function statusBadgeClass(status) {
    switch(status) {
      case 'draft': return 'secondary';
      case 'submitted': return 'info';
      case 'in_progress': return 'primary';
      case 'delivered': return 'success';
      case 'cancelled': return 'danger';
      default: return 'secondary';
    }
  }