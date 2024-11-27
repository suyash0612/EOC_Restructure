from robot.libraries.BuiltIn import BuiltIn

def get_selenium_browser_log():
    selib = BuiltIn().get_library_instance('SeleniumLibrary')
    return selib.driver.get_log('browser')