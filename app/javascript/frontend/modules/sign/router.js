import Sign from '@frontend/sign/Sign';
import alreadyAuthorized from '@frontend/core/services/alreadyAuthorized'

export const SIGN_ROUTER = {
  path: '/sign',
  component: Sign,
  beforeEnter: alreadyAuthorized
};
