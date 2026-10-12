#include <SDL3/SDL.h>
#include <cstdio>
int main(){
    SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS,"1");
    if(!SDL_Init(SDL_INIT_GAMEPAD)){std::fprintf(stderr,"SDL: %s\n",SDL_GetError());return 1;}
    int count=0;auto ids=SDL_GetJoysticks(&count);std::printf("Connected joysticks: %d\n",count);
    for(int n=0;n<count;++n){char guid[33]{};SDL_GUIDToString(SDL_GetJoystickGUIDForID(ids[n]),guid,sizeof(guid));
        auto joy=SDL_OpenJoystick(ids[n]);
        std::printf("name=%s guid=%s vendor=%04x product=%04x gamepad=%d axes=%d buttons=%d hats=%d\n",
            SDL_GetJoystickNameForID(ids[n]),guid,SDL_GetJoystickVendorForID(ids[n]),SDL_GetJoystickProductForID(ids[n]),SDL_IsGamepad(ids[n]),
            joy?SDL_GetNumJoystickAxes(joy):-1,joy?SDL_GetNumJoystickButtons(joy):-1,joy?SDL_GetNumJoystickHats(joy):-1);
        auto mapping=SDL_GetGamepadMappingForID(ids[n]);if(mapping){std::printf("mapping=%s\n",mapping);SDL_free(mapping);}
        if(joy)SDL_CloseJoystick(joy);
    }
    SDL_free(ids);SDL_Quit();return 0;
}
