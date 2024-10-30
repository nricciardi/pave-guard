import { Resolver, Field, ObjectType, Mutation, Args, Query, ID, Context, GraphQLExecutionContext } from '@nestjs/graphql';
import { AuthenticationService } from '../services/authentication/authentication.service';
import { LoginDto } from '../dto/login.dto';
import { CreateUserDto } from '../dto/create-user.dto';
import { UserService } from '../services/user/user.service';
import { Token, JwtAuthenticationGuard } from '../guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { User } from '../models/user.model';
import { JwtDto } from '../dto/jwt.dto';

@ObjectType()
export class UserQuery {
    @Field(() => ID)
    id: string;

    @Field()
    email: string;

    @Field()
    userCode: string;

    @Field()
    firstName: string;

    @Field()
    lastName: string;

    @Field()
    createdAt: Date;
}

@Resolver(() => UserQuery)
export class UserResolver {
  constructor(
    private readonly userService: UserService,
    private readonly authService: AuthenticationService,
  ) {}

  @Query(() => UserQuery)
  @UseGuards(JwtAuthenticationGuard)
  async me(
        @Context() context: GraphQLExecutionContext,
        @Token() token: JwtDto
    ) {

    const currentUser = this.authService.getUserFromToken(token);
    
    return currentUser;
  }
}
