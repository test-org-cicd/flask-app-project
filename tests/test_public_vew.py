from flask import url_for


class TestPublicView:

    def test_homepage_view(self, testapp):
        """
        Test that homepage is accessible
        """
        response = testapp.get(url_for('public.homepage'))
        assert response.status_code == 200
        assert "Welcome to 2022" in response
