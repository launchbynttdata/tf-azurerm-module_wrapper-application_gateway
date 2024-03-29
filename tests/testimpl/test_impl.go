package common

import (
	"context"
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v5"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionID) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID is not set in the environment variables ")
	}

	cred, err := azidentity.NewDefaultAzureCredential(nil)

	if err != nil {
		t.Fatalf("Unable to get credentials: %e\n", err)
	}

	clientFactory, err := armnetwork.NewClientFactory(subscriptionID, cred, nil)
	if err != nil {
		t.Fatalf("Unable to get clientFactory: %e\n", err)
	}

	applicationGatewayClient := clientFactory.NewApplicationGatewaysClient()

	expectedGatewayNames := terraform.OutputMap(t, ctx.TerratestTerraformOptions(), "appgw_name")
	expectedResourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")

	for _, expectedGatewayName := range expectedGatewayNames {
		t.Run("GatewayExists_"+expectedGatewayName, func(t *testing.T) {
			actualGateway, err := applicationGatewayClient.Get(context.Background(), expectedResourceGroupName, expectedGatewayName, nil)
			if err != nil {
				t.Fatalf("Error getting Application Gateway: %v", err)
			}
			assert.Equal(t, expectedGatewayName, *actualGateway.Name, "Application Gateway name didn't match expected.")
		})
	}
}
