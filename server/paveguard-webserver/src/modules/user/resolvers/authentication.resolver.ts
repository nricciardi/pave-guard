import { Resolver, Field, ObjectType, Mutation, Args, Query } from '@nestjs/graphql';
import { AuthenticationService } from '../services/authentication/authentication.service';
import { LoginDto } from '../dto/login.dto';
import { CreateUserDto } from '../dto/create-user.dto';

@ObjectType()
export class AuthenticationQuery {
  @Field()
  token: string;
}

@Resolver(() => AuthenticationQuery)
export class AuthenticationResolver {
  constructor(
    private readonly authenticationService: AuthenticationService
  ) {}

  @Mutation(() => AuthenticationQuery)
  async signup(
    @Args() input: CreateUserDto
  ) {
    return this.authenticationService.signup(input);
  }

  @Query(() => AuthenticationQuery)
  async login(
    @Args() input: LoginDto
  ) {
    return this.authenticationService.login(input);
  }
}
