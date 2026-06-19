export const getAsaasConfig = () => {
  // Use Sandbox environment by default unless specifically overridden
  const isProduction = Deno.env.get('ASAAS_ENVIRONMENT') === 'production';
  const apiKey = Deno.env.get('ASAAS_API_KEY') || '';
  
  const baseUrl = isProduction 
    ? 'https://api.asaas.com/v3'
    : 'https://sandbox.asaas.com/api/v3';

  return { baseUrl, apiKey };
};

export const asaasRequest = async (endpoint: string, method: string, body?: any) => {
  const { baseUrl, apiKey } = getAsaasConfig();
  
  if (!apiKey) {
    throw new Error("Asaas API Key is missing.");
  }

  const response = await fetch(`${baseUrl}${endpoint}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'access_token': apiKey
    },
    body: body ? JSON.stringify(body) : undefined
  });

  if (!response.ok) {
    const errText = await response.text();
    console.error(`Asaas Error [${response.status}]:`, errText);
    throw new Error(`Asaas API Error: ${response.statusText} - ${errText}`);
  }

  return await response.json();
};

// --- API Helpers ---

export const createCustomer = async (customerData: { name: string; cpfCnpj?: string; email: string; phone?: string }) => {
  return await asaasRequest('/customers', 'POST', customerData);
};

export const createSubscription = async (subData: { customer: string; billingType: string; value: number; nextDueDate: string; description: string; cycle: string; creditCard?: any; creditCardHolderInfo?: any }) => {
  return await asaasRequest('/subscriptions', 'POST', subData);
};

export const createPayment = async (payData: { customer: string; billingType: string; value: number; dueDate: string; description: string; creditCard?: any; creditCardHolderInfo?: any }) => {
  return await asaasRequest('/payments', 'POST', payData);
};
