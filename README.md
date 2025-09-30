```
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

type TokenResponse struct {
	AccessToken string `json:"access_token"`
	TokenType   string `json:"token_type"`
	ExpiresIn   int    `json:"expires_in"`
}

func getAzureToken(tenantID, clientID, clientSecret, resource string) (string, error) {
	url := fmt.Sprintf("https://login.microsoftonline.com/%s/oauth2/token", tenantID)

	data := fmt.Sprintf("grant_type=client_credentials&client_id=%s&client_secret=%s&resource=%s",
		clientID, clientSecret, resource)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer([]byte(data)))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	client := http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("failed to get token: %s", body)
	}

	var tokenRes TokenResponse
	err = json.Unmarshal(body, &tokenRes)
	if err != nil {
		return "", err
	}

	return tokenRes.AccessToken, nil
}

func callDatabricksAPI(token, databricksURL string) error {
	url := databricksURL + "/api/2.0/clusters/list"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+token)

	client := http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	fmt.Println("Response:", string(body))

	return nil
}


func main() {
	tenantID := os.Getenv("AZURE_TENANT_ID")
	clientID := os.Getenv("AZURE_CLIENT_ID")
	clientSecret := os.Getenv("AZURE_CLIENT_SECRET")
	resource := "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d" // Azure Databricks resource ID
	databricksURL := "https://<your-region>.azuredatabricks.net"

	token, err := getAzureToken(tenantID, clientID, clientSecret, resource)
	if err != nil {
		fmt.Println("Error getting token:", err)
		return
	}
```
	err = callDatabricksAPI(token, databricksURL)
	if err != nil {
		fmt.Println("Error calling Databricks API:", err)
	}
}
