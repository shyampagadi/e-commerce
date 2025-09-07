import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 10 }, // Ramp up
    { duration: '5m', target: 10 }, // Stay at 10 users
    { duration: '2m', target: 0 },  // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'], // 95% of requests under 200ms
    http_req_failed: ['rate<0.1'],    // Error rate under 10%
  },
};

const BASE_URL = 'http://localhost:8080';

export default function () {
  // Test API Gateway health
  let response = http.get(`${BASE_URL}/actuator/health`);
  check(response, {
    'API Gateway health check': (r) => r.status === 200,
  });

  // Test customer API
  response = http.get(`${BASE_URL}/api/customer/owners`);
  check(response, {
    'Customer API responds': (r) => r.status === 200,
  });

  // Test vet API
  response = http.get(`${BASE_URL}/api/vet/vets`);
  check(response, {
    'Vet API responds': (r) => r.status === 200,
  });

  sleep(1);
}
