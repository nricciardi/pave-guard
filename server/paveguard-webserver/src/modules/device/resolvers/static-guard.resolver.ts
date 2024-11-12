import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { DeviceQuery } from './device.resolver';
import { StaticGuardService } from '../services/static-guard/static-guard.service';
import { CreateStaticGuardDto } from '../dto/create-static-guard.dto';


@ObjectType()
export class StaticGuardQuery extends DeviceQuery {

  @Field()
  street: string;

  @Field()
  latitude: number;

  @Field()
  longitude: number;
}


@Resolver(() => StaticGuardQuery)
export class StaticGuardResolver {
  constructor(
    private readonly staticGuardService: StaticGuardService,
  ) {}

  @Query(() => [StaticGuardQuery])
  @UseGuards(AdminGuard)
  async staticGuards() {
    return this.staticGuardService.findAll();
  }

  @Mutation(() => StaticGuardQuery)
  @UseGuards(AdminGuard)
  async createStaticGuard(
    @Args() input: CreateStaticGuardDto,
  ) {
    return this.staticGuardService.create(input);
  }
}

