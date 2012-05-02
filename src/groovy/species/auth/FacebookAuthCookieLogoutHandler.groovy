package species.auth

import org.springframework.security.web.authentication.logout.LogoutHandler
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.springframework.security.core.Authentication
import javax.servlet.http.Cookie
import org.apache.log4j.Logger

import species.utils.Utils;

class FacebookAuthCookieLogoutHandler implements LogoutHandler {

	private static final Logger logger = Logger.getLogger(this)

	FacebookAuthUtils facebookAuthUtils

	void logout(HttpServletRequest httpServletRequest,
	HttpServletResponse httpServletResponse,
	Authentication authentication) {

		logger.info("Cleanup Facebook cookies")
		Cookie cookie = facebookAuthUtils.getAuthCookie(httpServletRequest)
		if (cookie != null) {
			cookie.maxAge = 0
			cookie.path = '/'
			cookie.domain = "."+Utils.getDomain(httpServletRequest);
			httpServletResponse.addCookie(cookie)
		}
		
		Cookie cookie2 = facebookAuthUtils.getFBLoginCookie(httpServletRequest)
		if (cookie2 != null) {
			cookie2.maxAge = 0
			cookie2.path = '/'
			cookie2.domain = "."+Utils.getDomain(httpServletRequest);
			httpServletResponse.addCookie(cookie2)
		}
	}

	
}
