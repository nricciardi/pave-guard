# Flutter Responsive Admin/Dashboard Template

## [Live Preview](https://abuanwar072.github.io/Flutter-Responsive-Admin-Panel-or-Dashboard/#/)

I've created a step-by-step video tutorial to guide you through the process of building this responsive admin panel. **[Watch it on YouTube](https://youtu.be/_uOgXpEHNbc)**

### Checkout [Serverpod.dev](https://cutt.ly/Per1Z7ri) - The Flutter Backend

Flutter V2.\* has officially introduced web support on its stable branch. Today, I'm excited to present a Flutter-based Admin panel, often referred to as a dashboard UI. This Flutter dashboard template, which you can find on GitHub, is a comprehensive solution for your app's backend needs. It comes with a wide array of features including charts, tables, and neatly designed info cards.

This flutter dashboard library is versatile; it's tailored to work seamlessly on the Web, macOS app, tablets, and both Android and iOS phones. The principle 'code once, run everywhere' truly comes to life with this.

**Packages we are using:**

- flutter_svg: [link](https://pub.dev/packages/flutter_svg)
- google_fonts: [link](https://pub.dev/packages/google_fonts)
- provider: [link](https://pub.dev/packages/provider)

**Fonts**

- Poppins [link](https://fonts.google.com/specimen/Poppins)

### Responsive Admin Panel or Dashboard Final UI Preview

![Preview](/gif.gif)

![App UI](/ui.png)

## Login

The `login_screen.dart` file defines the `LoginScreen` widget, which provides a user interface for logging into the PaveGuard application. This screen leverages the `FlutterLogin` package to create a visually appealing and functional login form.

### Widget Structure

#### `build(BuildContext context)`

The `build` method is the core of the `LoginScreen` widget. It returns a `FlutterLogin` widget, which is a pre-built login form provided by the `flutter_login` package. This widget is highly customizable and allows for a seamless login experience.

#### Title

The `title` property is set to 'PAVEGUARD', which will be displayed at the top of the login form. This helps in branding and gives the user a clear indication of the application they are logging into.

#### Theme

The `theme` property customizes the appearance of the login form. It uses the `LoginTheme` class to define the following colors:
- `primaryColor`: Set to `Colors.black`, which will be the main color of the login form.
- `accentColor`: Set to `Colors.purple`, used for highlighting important elements.
- `errorColor`: Set to `Colors.deepOrange`, used to indicate errors.

These color choices ensure that the login form is visually consistent with the overall design of the PaveGuard application.

#### Callbacks

The `FlutterLogin` widget requires several callback functions to handle user interactions:

- **onLogin**: This callback is triggered when the user attempts to log in. It is linked to the `_authUser` function, which should contain the logic for authenticating the user.
- **onSubmitAnimationCompleted**: This callback is called when the login animation is completed. It navigates the user to the `MainScreen` of the application. The `Navigator.of(context).pushReplacement` method is used to replace the current screen with the `MainScreen`, passing the `token` as an argument.
- **hideForgotPasswordButton**: This boolean property is set to `true` to hide the "Forgot Password" button, simplifying the login form.

## Stats Screen

The `stats_screen.dart` file defines the `StatsScreen` widget, which provides a detailed statistical view of the severity of cracks and potholes on various streets. This screen utilizes the `fl_chart` package to display line charts representing the data.

### Constants and Variables

- **lineChartWidth**: A constant that defines the width of the line charts.
- **granularity**: An integer that determines the granularity of the data displayed in the charts.

### SeverityData Class

The `SeverityData` class holds the severity data and corresponding dates. It provides a method to filter recent data based on a specified number of days.

#### Methods

- **getRecentData(int days, {DateTime? currentDate})**: Filters and returns severity data for the specified number of recent days.

### getLineChart Function

The `getLineChart` function generates a line chart for the given severity data. It uses the `LineChart` widget from the `fl_chart` package.

#### Parameters

- **entry**: A `MapEntry` containing a string key and `SeverityData` value.

#### Returns

- A `Widget` displaying the line chart or a message indicating no data is available.

### getCharts Function

The `getCharts` function creates a column of charts for cracks and potholes severity data.

#### Parameters

- **sev_entry**: A `MapEntry` containing severity data for cracks.
- **poth_entry**: A `MapEntry` containing severity data for potholes.

#### Returns

- A `Column` widget containing the charts.

### StateHeader Class

The `StateHeader` class is a stateless widget that displays the header for the statistics screen, including labels for cracks and potholes and a slider for adjusting granularity.

#### Properties

- **slider**: A `Widget` representing the slider for adjusting granularity.

#### Methods

- **build(BuildContext context)**: Builds the header widget.

### StatsScreen Class

The `StatsScreen` class is a stateful widget that represents the main statistics screen. It fetches and displays severity data for various locations.

#### Properties

- **data**: An instance of `MeData` containing user data.
- **token**: A string representing the authentication token.
- **searched_text**: A string representing the text used for searching locations.

#### Methods

- **initState()**: Initializes the state, fetches location and severity data, and sets up the timer.
- **build(BuildContext context)**: Builds the main statistics screen.

## Planning Screen Documentation

The `planning_screen.dart` file defines the `PlanningScreen` widget, which provides an interface for planning and managing maintenance tasks. This screen utilizes the `table_calendar` package to display a calendar and allows users to add and edit maintenance tasks.

### CalendarData Class

The `CalendarData` class holds the location data and the status of the maintenance task (done or not).

#### Properties

- **location**: An instance of `LocationData` representing the location of the maintenance task.
- **done**: A boolean indicating whether the maintenance task is completed.

#### Constructor

- **CalendarData(this.location, this.done)**: Initializes the `CalendarData` with the given location and status.

### PlanningScreen Class

The `PlanningScreen` class is a stateful widget that represents the main planning screen. It fetches and displays maintenance tasks on a calendar.

#### Properties

- **data**: An instance of `MeData` containing user data.
- **token**: A string representing the authentication token.

#### Constructor

- **PlanningScreen(this.data, this.token, {Key? key})**: Initializes the `PlanningScreen` with the given user data and token.

#### Methods

##### initState()

Initializes the state, fetches location and planning data.

##### _fetchLocations()

Fetches the list of locations from the server using the `QueryLocationManager`.

##### _fetchPlanningData()

Fetches the planning data from the server using the `PlanningQueryManager`.

##### _showDialogAdd(BuildContext context, DateTime selectedDay)

Displays a dialog for adding a new maintenance task. The user can select a location and enter a description.

##### _showEditDialog(BuildContext context, DateTime selectedDay)

Displays a dialog for editing an existing maintenance task. The user can select a maintenance task, mark it as done, and update the description.

##### build(BuildContext context)

Builds the main planning screen, displaying a calendar and buttons for adding and editing maintenance tasks.