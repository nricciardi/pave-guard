import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { RoadPotholeService } from '../services/road-pothole/road-pothole.service';
import { CreateRoadPotholeTelemetryDto } from '../dto/create-road-pothole-telemetry.dto';


@ObjectType()
export class RoadPotholeTelemetryQuery extends TelemetryQuery {

  @Field()
  severity: number;
}

@Resolver(() => RoadPotholeTelemetryQuery)
export class RoadPotholeTelemetryResolver {
  constructor(
    private readonly roadPotholeTelemetryService: RoadPotholeService
  ) {}

  @Query(() => [RoadPotholeTelemetryQuery])
  @UseGuards(AdminGuard)
  async roadPotholeTelemetries() {
    return this.roadPotholeTelemetryService.findAll();
  }

  @Mutation(() => RoadPotholeTelemetryQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createRoadPotholeTelemetry(
    @Args() input: CreateRoadPotholeTelemetryDto,
  ) {
    return this.roadPotholeTelemetryService.create(input);
  }
}

