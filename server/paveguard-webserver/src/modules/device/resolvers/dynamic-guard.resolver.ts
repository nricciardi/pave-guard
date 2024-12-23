import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { ForbiddenException, UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { DeviceQuery } from './device.resolver';
import { CreateDynamicGuardDto } from '../dto/create-dynamic-guard.dto';
import { DynamicGuardService } from '../services/dynamic-guard/dynamic-guard.service';
import { JwtAuthenticationGuard, Token } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { JwtDto } from 'src/modules/user/dto/jwt.dto';
import { UserService } from 'src/modules/user/services/user/user.service';
import { ForbiddenError } from '@nestjs/apollo';


@ObjectType()
export class DynamicGuardQuery extends DeviceQuery {

  @Field()
  userId: string;
}


@Resolver(() => DynamicGuardQuery)
export class DynamicGuardResolver {
  constructor(
    private readonly dynamicGuardService: DynamicGuardService,
    private readonly userService: UserService,
  ) {}

  @Query(() => [DynamicGuardQuery])
  @UseGuards(JwtAuthenticationGuard)
  async dynamicGuards(
    @Token() token: JwtDto
  ) {

    if(!token)
      return new ForbiddenException("token missed");

    const user = await this.userService.findById(token.userId);

    if (user.admin)
      return this.dynamicGuardService.findAll();

    return this.dynamicGuardService.findByUserId(user.id);
  }

  @Mutation(() => DynamicGuardQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createDynamicGuard(
    @Token() token: JwtDto,
    @Args() input: CreateDynamicGuardDto,
  ) {

    const user = await this.userService.findById(token.userId);

    if (!user.admin && user.id != input.userId)
      return new ForbiddenError("only admin can create a dynamic guard device for another user");

    return this.dynamicGuardService.create(input);
  }
}

