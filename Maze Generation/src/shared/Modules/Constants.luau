local Constants = {}

Constants.GAME_NAME = "Maze Generation"
Constants.GAME_VERSION = "1.0.0"
Constants.GAME_AUTHOR = "Kele"


Constants.SHARED_BASE = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
-- #endregion


-- #region Package Paths 
Constants.PACKAGE_PATHS = {}
Constants.PACKAGE_PATHS.BASE = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
Constants.PACKAGE_PATHS.KNIT = Constants.PACKAGE_PATHS.BASE:WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit")
Constants.PACKAGE_PATHS.JANITOR = Constants.PACKAGE_PATHS.BASE:WaitForChild("howmanysmall_janitor@1.18.3"):WaitForChild("janitor")
Constants.PACKAGE_PATHS.PROMISE = Constants.PACKAGE_PATHS.BASE:WaitForChild("howmanysmall_typed-promise@4.0.6").Promise
Constants.PACKAGE_PATHS.ZONE = Constants.PACKAGE_PATHS.BASE:WaitForChild("legendoj1_zoneplus@3.2.2"):WaitForChild("zoneplus")
-- #endregion

-- #region Controllers
Constants.CONTROLLERS = {}
Constants.CONTROLLERS.MAZE_CONTROLLER = "MazeController"
Constants.CONTROLLERS.UI_CONTROLLER = "UIController"
-- #endregion

-- #region Maze Constants
Constants.MAZE = {}
Constants.MAZE.MAZE_SIZE = 10
Constants.MAZE.MAZE_HEIGHT = 10
Constants.MAZE.MAZE_WIDTH = 10
-- #endregion

return Constants