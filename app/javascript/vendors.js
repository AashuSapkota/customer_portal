const token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMTEsImV4cCI6MTc0MzkyNDc5OX0.-21eygNt7vdNQXY1plnR9Ab2mW76Bmgg1cZckF_gvxo'
document.addEventListener('DOMContentLoaded', function() {
    // Load vendors list
    if (document.getElementById('vendors-index')) {
      fetchVendors();
    }
  
    // Load single vendor
    if (document.getElementById('vendor-show')) {
      const vendorId = document.getElementById('vendor-show').dataset.vendorId;
      fetchVendor(vendorId);
    }
  });
  
  function fetchVendors() {
    fetch('/api/v1/vendors', {
      headers: {
        // 'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      const tableBody = document.querySelector('#vendors-table tbody');
      tableBody.innerHTML = data.map(vendor => `
        <tr>
          <td>${vendor.name}</td>
          <td>${vendor.contact_email}</td>
          <td>${vendor.contact_phone}</td>
          <td>
            <a href="/vendors/${vendor.id}" class="btn btn-sm btn-primary">View</a>
            <a href="/vendors/${vendor.id}/edit" class="btn btn-sm btn-secondary">Edit</a>
            <button class="btn btn-sm ${vendor.preferred ? 'btn-success' : 'btn-outline-success'}" 
                    onclick="setPreferred(${vendor.id})">
              ${vendor.preferred ? 'Preferred' : 'Set Preferred'}
            </button>
          </td>
        </tr>
      `).join('');
    });
  }
  
  function fetchVendor(id) {
    fetch(`/api/v1/vendors/${id}`, {
      headers: {
        // 'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    })
    .then(response => response.json())
    .then(vendor => {
      document.getElementById('vendor-name').textContent = vendor.name;
      document.getElementById('vendor-email').textContent = vendor.contact_email;
      // ... populate other fields ...
    });
  }
  
  function setPreferred(vendorId) {
    fetch(`/api/v1/vendors/${vendorId}/set_preferred`, {
      method: 'POST',
      headers: {
        // 'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      // Refresh the list
      fetchVendors();
    });
  }