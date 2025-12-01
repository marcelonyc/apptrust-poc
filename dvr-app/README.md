# DVR App

This document provides an overview of the `dvr-app` folder and the steps executed in the `build.sh` script. It also includes references to JFrog documentation for using the JFrog CLI and the AppTrust REST API.

## Prerequisites

### Setting Up Project, Repositories, and Application in Artifactory and AppTrust

Before proceeding, ensure you have the necessary permissions to create projects, repositories, and applications in JFrog Artifactory and AppTrust.

#### 1. Create a Project in Artifactory
1. Log in to your JFrog Artifactory instance.
2. Navigate to the **Administration** tab and select **Projects**.
3. Click **New Project** and provide the required details:
    - **Project Key**: A unique identifier for the project.
    - **Project Name**: A descriptive name for the project.
    - **Description**: (Optional) Add a brief description of the project.
4. Save the project.

#### 2. Create Repositories
1. Within the newly created project, navigate to the **Repositories** section.
2. Create the required repositories:
    - **Local Repository**: For storing build artifacts.
    - **Remote Repository**: For proxying external dependencies.
    - **Virtual Repository**: For aggregating local and remote repositories.
3. Configure repository settings such as package type, layout, and permissions as needed.

#### 3. Register the Application in AppTrust
1. Access the AppTrust dashboard.
2. Navigate to the **Applications** section and click **New Application**.
3. Provide the following details:
    - **Application Name**: A unique name for the application.
    - **Description**: (Optional) Add a brief description of the application.
    - **Associated Repositories**: Link the application to the relevant repositories in Artifactory.
4. Save the application.


### Adding AppTrust Server to JFrog CLI

To configure the AppTrust server in JFrog CLI, use the following command:

```bash
jf config add AppTrustC \
    --artifactory-url=https://<JFrog URL>/artifactory \
    --access-token=$JF_TOKEN
```

Replace `$JF_TOKEN` with your JFrog access token. This configuration ensures that the JFrog CLI can interact with the AppTrust server for artifact management and scanning.


### Environment Configuration

Create a `.env_apptrust` file in your home directory (`~/.env_apptrust`) to store the required environment variables. Use the `home_dot_env_apptrust` template as a reference for the structure and required fields.

To populate the `.env_apptrust` file:

1. Copy the `home_dot_env_apptrust` template to your home directory:
    ```bash
    cp path/to/home_dot_env_apptrust ~/.env_apptrust
    ```

2. Open the `.env_apptrust` file in a text editor and fill in the required values:
    - `APPTRUST_API_KEY`: Your AppTrust API key.
    - `JFROG_CLI_USER`: Your JFrog CLI username.
    - `JFROG_CLI_PASSWORD`: Your JFrog CLI password or API token.
    - `ARTIFACTORY_URL`: The URL of your JFrog Artifactory instance.

3. Save the file and ensure it has the correct permissions:
    ```bash
    chmod 600 ~/.env_apptrust
    ```

The `build.sh` script will automatically source this file to retrieve the necessary environment variables.
Before running the `build.sh` script, ensure the following:
- JFrog CLI is installed and configured. Refer to the [JFrog CLI documentation](https://jfrog.com/confluence/display/CLI/JFrog+CLI) for installation and setup instructions.
- Access to the AppTrust REST API is configured. Refer to the [AppTrust API documentation](https://jfrog.com/confluence/display/JFROG/AppTrust+REST+API) for details.

## Steps Executed in `build.sh`

The `build.sh` script automates the following steps:

1. **Dependency Installation**  
    Installs the required dependencies for the `dvr-app` project.

2. **Building the Application**  
    Compiles the source code and prepares the application for deployment.

3. **Artifact Upload to JFrog Artifactory**  
    Uses the JFrog CLI to upload the built artifacts to the configured JFrog Artifactory repository.  
    Refer to the [JFrog CLI Upload Command](https://jfrog.com/confluence/display/CLI/CLI+for+JFrog+Artifactory#CLIforJFrogArtifactory-UploadingFiles) for more details.

4. **AppTrust Scanning**  
    Invokes the AppTrust REST API to scan the uploaded artifacts for security and compliance.  
    Refer to the [AppTrust REST API Guide](https://jfrog.com/confluence/display/JFROG/AppTrust+REST+API) for API usage.

5. **Verification and Reporting**  
    Retrieves the scan results from the AppTrust API and generates a report.

## Running the Script

To execute the `build.sh` script, run the following command in the terminal:

```bash
./build.sh
```

Ensure you have the necessary permissions and environment variables configured before running the script.

## References

- [JFrog CLI Documentation](https://jfrog.com/confluence/display/CLI/JFrog+CLI)
- [AppTrust REST API Documentation](https://jfrog.com/confluence/display/JFROG/AppTrust+REST+API)
- [JFrog Artifactory Documentation](https://jfrog.com/confluence/display/JFROG/Artifactory)

For further assistance, contact your system administrator or refer to the official JFrog documentation.