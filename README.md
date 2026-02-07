# WebPageTest

This is the official repository for the performance-testing code that runs at [webpagetest.org](https://www.webpagetest.org).

---

## 🚀 Quick Start: Podman Deployment (Windows)

This repository includes a one-click deployment script for Windows users using **Podman**. It sets up a local WebPageTest server and multi-browser agents (Chrome, Firefox, and Edge).

### Prerequisites
1.  **Podman**: Ensure Podman is installed and the machine is initialized (`podman machine start`).
2.  **PowerShell**: The script is built for PowerShell.

### Installation & Deployment

1.  **Clone the repository**:
    ```powershell
    git clone https://github.com/RamK73/WebPageTest
    cd WebPageTest
    ```

2.  **Run the deployment script**:
    ```powershell
    .\deploy-wpt.ps1
    ```
    *This script will automate the building of images and starting of containers.*

### Accessing the Instance
- **Web Interface**: [http://localhost](http://localhost)
- **Results Folder**: Located at `./www/results` (mapped as a persistent volume).

### Monitoring
- **Server Logs**: `podman logs -f wpt-server`
- **Agent Logs**: 
  - `podman logs -f wpt-agent-chrome`
  - `podman logs -f wpt-agent-firefox`
  - `podman logs -f wpt-agent-edge`

---

- 🥡 [Install your own instance](https://docs.webpagetest.org/private-instances/)

## Troubleshooting private instances

If your instance runs, but you’re having issues configuring agents, navigate to `http://{your_instance’s_ip}/install` to [check for a valid configuration](https://docs.webpagetest.org/private-instances/#web-server-install).

## Testing

WebPageTest uses [PHPUnit](https://phpunit.de) for unit tests. To set up and run the unit tests:

1. Install [Composer](https://getcomposer.org)
2. Install [apcu](https://www.php.net/manual/en/book.apcu.php)
3. Add the line `apc.enable_cli='on'` to your php.ini
4. Run `composer install`
5. Run `composer test`

## Contributing

There are separate lines of development under different licenses (pull requests accepted to either):

- The `master` branch where most active development occurs has the [Polyform Shield 1.0.0 license](LICENSE.md)
- The `apache` branch has the more permissive [Apache 2.0 license](https://opensource.org/licenses/Apache-2.0)

### Code style

WebPageTest uses PSR12 coding conventions for PHP linting and formatting.
For JavaScript and CSS formatting we use Prettier with its default configuration.
Additionally we use Stylelint for CSS linting.

Before you send a pull request please make sure to run: `composer lint && composer format`.

Alternatively you can run

 - `composer lint:php && composer format:php` if you only touched PHP code, or
 - `composer lint:css && composer format:prettier` if you only touched CSS or JavaScript code

### VSCode integration

If you use VSCode you might find it helpful to install Prettier and PHP Intelephence plugins and use these in your "settings.json":

```
{
  "[php]": {
    "editor.tabSize": 4
  },

  // uncomment to reformat on every file save
  //"editor.formatOnSave": true,

  "phpcs.standard": "PSR12",

  "files.trimTrailingWhitespace": true,

  "files.eol": "\n",

  "files.associations": {
    "*.inc": "php"
  }
}
```
