from .user import User, UserCreate, UserUpdate
from .token import Token, TokenPayload, RefreshTokenRequest
from .country import Country # , CountryCreate # Add schemas as needed
from .city import City,CityDetail # , CityCreate
from .place import Place,PlaceDetail
from .user_activity import VisitHistoryEntry # <<< Add this
from .weather import WeatherCondition
from .weather import OpenMeteoForecastResponse
# Import other schemas